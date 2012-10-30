//  Created by Jens Riemschneider on 9/18/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.

#import "BlazeBallView.h"
#import "MatrixUtils.h"
#import "Scene.h"
#import "SceneObject.h"
#import "UIScene.h"
#import "Controller.h"
#import "GameController.h"
#import "LevelSelectionController.h"
#import "Model.h"
#import "Frame.h"
#import "ModelRegistry.h"
#import "HighscoreRepo.h"

@implementation BlazeBallView

@synthesize level = _level;
@synthesize highscoreRepo = _highscoreRepo;
@synthesize bronzeScore = _bronzeScore;
@synthesize silverScore = _silverScore;
@synthesize goldScore = _goldScore;
@synthesize arcade = _arcade;
@synthesize scoreFromLastLevel = _scoreFromLastLevel;
@synthesize bonusJump = _bonusJump;
@synthesize bonusTime = _bonusTime;
@synthesize stopped = _stopped;


- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;

    if ([self respondsToSelector:@selector(contentScaleFactor)]) {
        _scale = [[UIScreen mainScreen] scale];
        self.contentScaleFactor = _scale;
        _eaglLayer.contentsScale = _scale;
    }
    
    _multiSample = NO;
    
    self.multipleTouchEnabled = YES;
}

- (void)setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGL ES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupBuffers {
    _width = self.frame.size.width * _scale;
    _height = self.frame.size.height * _scale;
    _aspect = _width / _height;
    
    GLuint depthRenderbuffer;
    if (!_multiSample) {
        glGenRenderbuffers(1, &depthRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _width, _height);    
    }

    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];

    glGenFramebuffers(1, &_resolveFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _resolveFrameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);

    if (!_multiSample) {
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
        _sampleFramebuffer = _resolveFrameBuffer;
    }
    else {
        glGenFramebuffers(1, &_sampleFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _sampleFramebuffer);

        GLuint sampleColorRenderbuffer;
        glGenRenderbuffers(1, &sampleColorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, sampleColorRenderbuffer);

        glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_RGBA8_OES, _width, _height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, sampleColorRenderbuffer);

        GLuint sampleDepthRenderbuffer;
        glGenRenderbuffers(1, &sampleDepthRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, sampleDepthRenderbuffer);

        glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_DEPTH_COMPONENT16, _width, _height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, sampleDepthRenderbuffer);
    }
}

- (void)renderSkyObject {
    SceneObject *skyObj = _controller.scene.skyObj;
    if  (!skyObj) {
        return;
    }
    
    glUseProgram(_skyShaderProgram);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
    
    Model *model = skyObj.model;
    glBindTexture(GL_TEXTURE_2D, model.texture);
    glUniform1i(_skyTextureLoc, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, model.vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, model.indexBuffer);
    
    glVertexAttribPointer(_skyPosLoc, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_skyTexCoordLoc, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)(sizeof(float) * 6));
    
    glDrawElements(GL_TRIANGLES, model.triangleCount * 3, GL_UNSIGNED_SHORT, 0);
}

- (void)renderSceneObject:(SceneObject *)obj {
    if (obj.hidden) {
        return;
    }

    CATransform3D modelTransform = obj.transform;
    glUniformMatrix4fv(_modelLoc, 1, GL_FALSE, (GLfloat*)&modelTransform);
    
    Model *model = obj.model;
    glBindTexture(GL_TEXTURE_2D, model.texture);
    glUniform1i(_textureLoc, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, model.vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, model.indexBuffer);
    
    glVertexAttribPointer(_posLoc, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_normalLoc, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)(sizeof(float) * 3));
    glVertexAttribPointer(_texCoordLoc, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)(sizeof(float) * 6));
    
    glDrawElements(GL_TRIANGLES, model.triangleCount * 3, GL_UNSIGNED_SHORT, 0);
}

- (void)renderSceneObjects {
    glUseProgram(_sceneShaderProgram);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    CATransform3D proj = CATransform3DMakeProjection(60, _aspect, 1, 1000);
    CATransform3D view = _controller.scene.view;
    
    glUniformMatrix4fv(_projLoc, 1, GL_FALSE, (GLfloat*)&proj);
    glUniformMatrix4fv(_viewLoc, 1, GL_FALSE, (GLfloat*)&view);
    
    for (SceneObject *obj in _controller.scene.objects) {
        [self renderSceneObject:obj];
    }
}

- (void)renderUiSceneObject:(SceneObject *)obj {
    if (obj.hidden) {
        return;
    }
    
    CATransform3D modelTransform = obj.transform;
    glUniformMatrix4fv(_uiModelLoc, 1, GL_FALSE, (GLfloat*)&modelTransform);
    
    glUniform4fv(_uiColorLoc, 1, obj.color);
    
    Model *model = obj.model;
    glBindTexture(GL_TEXTURE_2D, model.texture);
    glUniform1i(_uiTextureLoc, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, model.vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, model.indexBuffer);
    
    glVertexAttribPointer(_uiPosLoc, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_uiTexCoordLoc, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)(sizeof(float) * 6));
    
    glDrawElements(GL_TRIANGLES, model.triangleCount * 3, GL_UNSIGNED_SHORT, 0);
}

- (void)renderUiSceneObjects {
    glUseProgram(_uiSceneShaderProgram);
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    for (SceneObject *obj in _controller.uiScene.objects) {
        [self renderUiSceneObject:obj];
    }
}

- (void)render:(CADisplayLink*)displayLink {
    if (_stopped) {
        return;
    }
    
    [_controller update:displayLink.timestamp];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _sampleFramebuffer);
    glViewport(0, 0, _width, _height);

    glClearColor(0, 0, 0, 1);
    glClear(GL_DEPTH_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE0);

    [self renderSkyObject];
    [self renderSceneObjects];
    [self renderUiSceneObjects];
    
    if (_multiSample) {
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, _resolveFrameBuffer);
        glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, _sampleFramebuffer);
        glResolveMultisampleFramebufferAPPLE();
    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setupUi {
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    displayLink.frameInterval = 1;
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [UIAccelerometer sharedAccelerometer].delegate = self;
}

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    GLuint shaderHandle = glCreateShader(shaderType);
    
    const char* shaderStringUtf8 = [shaderString UTF8String];
    int shaderStringLen = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUtf8, &shaderStringLen);
    
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar msg[256];
        glGetShaderInfoLog(shaderHandle, sizeof(msg), 0, &msg[0]);
        NSString* msgStr = [NSString stringWithUTF8String:msg];
        NSLog(@"%@", msgStr);
        exit(1);
    }
    
    return shaderHandle;
}

- (void)setupSceneShaders {
    GLuint vertexShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
    
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar msg[256];
        glGetProgramInfoLog(programHandle, sizeof(msg), 0, &msg[0]);
        NSString* msgStr = [NSString stringWithUTF8String:msg];
        NSLog(@"%@", msgStr);
        exit(1);
    }
    
    glUseProgram(programHandle);
    
    _posLoc = glGetAttribLocation(programHandle, "pos");
    _texCoordLoc = glGetAttribLocation(programHandle, "texCoord");
    _normalLoc = glGetAttribLocation(programHandle, "normal");
    
    glEnableVertexAttribArray(_posLoc);
    glEnableVertexAttribArray(_texCoordLoc);
    glEnableVertexAttribArray(_normalLoc);

    _projLoc = glGetUniformLocation(programHandle, "proj");
    _viewLoc = glGetUniformLocation(programHandle, "view");
    _modelLoc = glGetUniformLocation(programHandle, "model");
    _textureLoc = glGetUniformLocation(programHandle, "texture");
    _lightPosLoc = glGetUniformLocation(programHandle, "lightPos");
    
    _sceneShaderProgram = programHandle;
}

- (void)setupUiSceneShaders {
    GLuint vertexShader = [self compileShader:@"UiSceneVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"UiSceneFragment" withType:GL_FRAGMENT_SHADER];
    
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar msg[256];
        glGetProgramInfoLog(programHandle, sizeof(msg), 0, &msg[0]);
        NSString* msgStr = [NSString stringWithUTF8String:msg];
        NSLog(@"%@", msgStr);
        exit(1);
    }
    
    glUseProgram(programHandle);
    
    _uiPosLoc = glGetAttribLocation(programHandle, "pos");
    _uiTexCoordLoc = glGetAttribLocation(programHandle, "texCoord");
    
    glEnableVertexAttribArray(_posLoc);
    glEnableVertexAttribArray(_texCoordLoc);
    
    _uiModelLoc = glGetUniformLocation(programHandle, "model");
    _uiTextureLoc = glGetUniformLocation(programHandle, "texture");
    _uiColorLoc = glGetUniformLocation(programHandle, "color");
    
    _uiSceneShaderProgram = programHandle;
}

- (void)setupSkyShaders {
    GLuint vertexShader = [self compileShader:@"SkyVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SkyFragment" withType:GL_FRAGMENT_SHADER];
    
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar msg[256];
        glGetProgramInfoLog(programHandle, sizeof(msg), 0, &msg[0]);
        NSString* msgStr = [NSString stringWithUTF8String:msg];
        NSLog(@"%@", msgStr);
        exit(1);
    }
    
    glUseProgram(programHandle);
    
    _skyPosLoc = glGetAttribLocation(programHandle, "pos");
    _skyTexCoordLoc = glGetAttribLocation(programHandle, "texCoord");
    
    glEnableVertexAttribArray(_posLoc);
    glEnableVertexAttribArray(_texCoordLoc);
    
    _skyTextureLoc = glGetUniformLocation(programHandle, "texture");
    
    _skyShaderProgram = programHandle;
}



- (void)setupLight {
    glUseProgram(_sceneShaderProgram);
    glUniform3f(_lightPosLoc, 100, 100, 300);
}

- (void)switchMode:(GameMode)mode {
    [_controller release];
    _currentMode = mode;
    
    Class controllerClass;
    switch (_currentMode) {
        case MODE_LEVEL_SELECTION: controllerClass = [LevelSelectionController class]; break;
        case MODE_LEVEL: controllerClass = [GameController class]; break;
        default: NSLog(@"Invalid game mode"); exit(1);
    }
    
    _controller = [[controllerClass alloc] initWithView:self andRegistry:_modelRegistry];
}

- (void)setupGame {
    _highscoreRepo = [[HighscoreRepo alloc] init];
    _modelRegistry = [[ModelRegistry alloc] init];
    [self switchMode:MODE_LEVEL_SELECTION];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupBuffers];
        [self setupSceneShaders];
        [self setupUiSceneShaders];
        [self setupSkyShaders];
        [self setupLight];
        [self setupUi];
        [self setupGame];
    }
    return self;
}

- (void)dealloc {
    [_context release];
    [_controller release];
    [_modelRegistry release];
    [_highscoreRepo release];
    [super dealloc];
}

- (CGPoint)toGl:(CGPoint)org {
    return CGPointMake(2 * org.y / (_height / _scale) - 1, 2 * org.x / (_width / _scale ) - 1);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint touchPt = [self toGl:[touch locationInView:self]];
        [_controller touchBegan:touch pos:touchPt at:event.timestamp];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint touchPt = [self toGl:[touch locationInView:self]];
        [_controller touchMove:touch pos:touchPt at:event.timestamp];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint touchPt = [self toGl:[touch locationInView:self]];
        [_controller touchEnd:touch pos:touchPt at:event.timestamp];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint touchPt = [self toGl:[touch locationInView:self]];
        [_controller touchCancelled:touch pos:touchPt at:event.timestamp];
    }
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    [_controller accelerate:acceleration];
}

- (void)setStopMusic:(BOOL)stopMusic {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];
    NSString *path = [docDirectory stringByAppendingPathComponent:@"options.plist"];

    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!options) {
        options = [[[NSMutableDictionary alloc] init] autorelease];
    }
    
    [options setObject:[NSString stringWithFormat:@"%i", stopMusic] forKey:@"music"];

    if (![options writeToFile:path atomically:NO]) {
        NSLog(@"Failed to write options file to %@", path);
    }
}

- (BOOL)stopMusic {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];
    NSString *path = [docDirectory stringByAppendingPathComponent:@"options.plist"];
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!options) {
        return NO;
    }

    return [[options objectForKey:@"music"] boolValue];
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

@end








