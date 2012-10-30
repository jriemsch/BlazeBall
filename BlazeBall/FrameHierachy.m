//  Created by Jens Riemschneider on 9/24/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.

#import "FrameHierachy.h"
#import "Frame.h"

@implementation FrameHierachy

@synthesize root = _root;

- (id)initWithRoot:(Frame *)root {
    self = [super init];
    if (self) {
        _root = root;
        [_root retain];
    }
    
    return self;
}

- (void)dealloc {
    [_root release];
    [super dealloc];
}

+ (NSString *)stripLine:(NSString *)line separator:(NSString *)separator {
    NSMutableString *content = [NSMutableString stringWithString:line];
    [content replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, [content length])]; 
    [content replaceOccurrencesOfString:separator withString:@"" options:0 range:NSMakeRange(0, [content length])];
    return [content stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";"]];
}

+ (CATransform3D)parseTransform:(NSString *)line {
    NSString *content = [self stripLine:line separator:@";"];
    NSArray *numbers = [content componentsSeparatedByString:@","];
    
    if ([numbers count] != 16) {
        NSLog(@"Invalid transform: %@", line);
        exit(1);
    }
    
    CATransform3D transform;
    int idx = 0;
    for (NSString *numberStr in numbers) {
        float number = [numberStr floatValue];
        (&transform.m11)[idx] = number;
        ++idx;
    }
    return transform;
}

+ (int)parseCount:(NSString *)line {
    NSString *content = [self stripLine:line separator:@";"];
    return [content intValue];
}

+ (void)parseVector:(NSString *)line into:(float*)vector withDimension:(int)dim skip:(NSCharacterSet*)skipChars {
    NSScanner *scanner = [NSScanner scannerWithString:line];
    scanner.charactersToBeSkipped = skipChars;
    
    for (int idx = 0; idx < dim; ++idx) {
        [scanner scanFloat:vector + idx];
    }
}

+ (void)parseTriangle:(NSString *)line into:(short*)triangle skip:(NSCharacterSet*)skipChars {
    NSScanner *scanner = [NSScanner scannerWithString:line];
    scanner.charactersToBeSkipped = skipChars;
    
    int cnt;
    [scanner scanInt:&cnt];
    if (cnt != 3) {
        NSLog(@"Invalid triangle: %@", line);
        exit(1);
    }

    int value;
    for (int idx = 0; idx < cnt; ++idx) {
        [scanner scanInt:&value];
        triangle[idx] = value;
    }
}

+ (NSString *)parseTexture:(NSString *)line {
    NSError *error = NULL;
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"^ *\\\"([^\\\"]+)\\\"" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRange wholeLine = NSMakeRange(0, [line length]);
    NSTextCheckingResult* match = [regEx firstMatchInString:line options:0 range:wholeLine];
    if (!match) {
        NSLog(@"Invalid texture: %@", line);
        exit(1);
    }
    
    NSRange range = [match rangeAtIndex:1];
    NSString *content = [line substringWithRange:range];
    return content;
}

+ (id)fromFile:(NSString *)fileName {
    NSLog(@"Loading frame hierarchy from file: %@", fileName);
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"x"];
    if (!filePath) {
        NSLog(@"File not found: %@", fileName);
        exit(1);
    }
    NSMutableString *content = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    if (!content) {
        NSLog(@"Content not read: %@", fileName);
        exit(1);
    }
    
    [content replaceOccurrencesOfString:@"\r\n" withString:@"\n" options:0 range:NSMakeRange(0, [content length])]; 
    [content replaceOccurrencesOfString:@"\r" withString:@"\n" options:0 range:NSMakeRange(0, [content length])]; 
    NSArray* lines = [content componentsSeparatedByString:@"\n"];
    
    NSError *error = NULL;
    NSRegularExpression *regExFrame = [NSRegularExpression regularExpressionWithPattern:@"^ *Frame ([^ ]+) \\{" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression *regExTransform = [NSRegularExpression regularExpressionWithPattern:@"^ *FrameTransformMatrix \\{" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression *regExMesh = [NSRegularExpression regularExpressionWithPattern:@"^ *Mesh ([^ ]+) \\{" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression *regExNormal = [NSRegularExpression regularExpressionWithPattern:@"^ *MeshNormals \\{" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression *regExTextureCoords = [NSRegularExpression regularExpressionWithPattern:@"^ *MeshTextureCoords \\{" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression *regExTexture = [NSRegularExpression regularExpressionWithPattern:@"^ *TextureFilename \\{" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSCharacterSet *skipChars = [NSCharacterSet characterSetWithCharactersInString:@" ,;"];
    
    NSMutableArray *frameStack = [NSMutableArray array];
    NSMutableDictionary *framesByLevel = [NSMutableDictionary dictionary];
    int openBraces = 0;
    
    BOOL readTransform = NO;
    BOOL readMeshSize = NO;
    BOOL readMesh = NO;
    BOOL readTriangleCount = NO;
    BOOL readTriangles = NO;
    BOOL readNormalCount = NO;
    BOOL readNormals = NO;
    BOOL readTextureCoordCount = NO;
    BOOL readTextureCoords = NO;
    BOOL readTexture = NO;
    
    int currentIdx = 0;
    
    Frame* root = nil;
    
    for (NSString *line in lines) {
        Frame *current = [frameStack lastObject];

        BOOL readingComponent = readMesh || readNormals || readTextureCoords || readTriangles;
        if (!readingComponent) {
            if ([line rangeOfString:@"{"].location != NSNotFound) {
                openBraces += 1;
            }

            if ([line rangeOfString:@"}"].location != NSNotFound) {
                NSNumber *key = [NSNumber numberWithInt:openBraces];
                Frame *closedFrame = [framesByLevel objectForKey:key];
                if (closedFrame) {
                    if (closedFrame != [frameStack lastObject]) {
                        NSLog(@"Invalid format. Cannot find correct closure for %@", closedFrame);
                        exit(1);
                    }
                    [frameStack removeLastObject];
                    [framesByLevel removeObjectForKey:key];
                }
                openBraces -= 1;
            }
        }
        
        if (readTransform) {
            // NSLog(@"reading transform %f", CACurrentMediaTime());
            current.transform = [self parseTransform:line];
            readTransform = NO;
        }
        else if (readMeshSize) {
            // NSLog(@"reading mesh %f", CACurrentMediaTime());
            current.meshSize = [self parseCount:line];
            current.mesh = calloc(current.meshSize, sizeof(Vertex));
            readMeshSize = NO;
            readMesh = YES;
            currentIdx = 0;
        }
        else if (readMesh) {
            Vertex *currentVertex = current.mesh + currentIdx;
            [self parseVector:line into:currentVertex->pos withDimension:3 skip:skipChars];
            ++currentIdx;
            if (currentIdx >= current.meshSize) {
                readMesh = NO;
                readTriangleCount = YES;
            }
        }
        else if (readTriangleCount) {
            // NSLog(@"reading triangles %f", CACurrentMediaTime());
            current.triangleCount = [self parseCount:line];
            current.triangles = calloc(current.triangleCount, sizeof(short) * 3);
            readTriangleCount = NO;
            readTriangles = YES;
            currentIdx = 0;
        }
        else if (readTriangles) {
            short* currentTriangle = current.triangles + currentIdx * 3;
            [self parseTriangle:line into:currentTriangle skip:skipChars];
            ++currentIdx;
            if (currentIdx >= current.triangleCount) {
                readTriangles = NO;
            }
        }
        else if (readNormalCount) {
            // NSLog(@"reading normals %f", CACurrentMediaTime());
            if ([self parseCount:line] != current.meshSize) {
                NSLog(@"mesh size and normal count are not identical");
                exit(1);
            }
            readNormalCount = NO;
            readNormals = YES;
            currentIdx = 0;
        }
        else if (readNormals) {
            Vertex *currentVertex = current.mesh + currentIdx;
            [self parseVector:line into:currentVertex->normal withDimension:3 skip:skipChars];
            ++currentIdx;
            if (currentIdx >= current.meshSize) {
                readNormals = NO;
            }
        }
        else if (readTextureCoordCount) {
            // NSLog(@"reading texture coords %f", CACurrentMediaTime());
            if ([self parseCount:line] != current.meshSize) {
                NSLog(@"mesh size and texture coord count are not identical");
                exit(1);
            }
            readTextureCoordCount = NO;
            readTextureCoords = YES;
            currentIdx = 0;
        }
        else if (readTextureCoords) {
            Vertex *currentVertex = current.mesh + currentIdx;
            [self parseVector:line into:currentVertex->tex withDimension:2 skip:skipChars];
            currentVertex->tex[0] = -currentVertex->tex[0];
            while (currentVertex->tex[0] > 1) {
                currentVertex->tex[0] -= 1;
            }
            currentVertex->tex[1] = currentVertex->tex[1] + 1;
            while (currentVertex->tex[1] > 1) {
                currentVertex->tex[1] -= 1;
            }
            ++currentIdx;
            if (currentIdx >= current.meshSize) {
                readTextureCoords = NO;
            }
        }
        else if (readTexture) {
            // NSLog(@"reading texture %f", CACurrentMediaTime());
            current.texture = [self parseTexture:line];
            readTexture = NO;
        }

        if (!readingComponent) {
            NSRange wholeLine = NSMakeRange(0, [line length]);
            NSTextCheckingResult* match = [regExFrame firstMatchInString:line options:0 range:wholeLine];
            if (match) {
                NSRange range = [match rangeAtIndex:1];
                NSString *frameName = [line substringWithRange:range];
                Frame *parent = [frameStack lastObject];
                Frame *frame = [[Frame alloc] initWithName:frameName];
                [frameStack addObject:frame];
                [framesByLevel setObject:frame forKey:[NSNumber numberWithInt:openBraces]];
                [parent.children addObject:frame];
                if (root == nil) {
                    root = frame;
                    [root retain];
                }
                [frame release];
            }
            
            match = [regExTransform firstMatchInString:line options:0 range:wholeLine];
            if (match) {
                readTransform = YES;
            }
            
            match = [regExMesh firstMatchInString:line options:0 range:wholeLine];
            if (match) {
                readMeshSize = YES;
            }
            
            match = [regExNormal firstMatchInString:line options:0 range:wholeLine];
            if (match) {
                readNormalCount = YES;
            }

            match = [regExTextureCoords firstMatchInString:line options:0 range:wholeLine];
            if (match) {
                readTextureCoordCount = YES;
            }
            
            match = [regExTexture firstMatchInString:line options:0 range:wholeLine];
            if (match) {
                readTexture = YES;
            }
        }
    }
    
    FrameHierachy* frames = [[self alloc] initWithRoot:root];
    [root release];
    [frames autorelease];
    return frames;
}

@end
