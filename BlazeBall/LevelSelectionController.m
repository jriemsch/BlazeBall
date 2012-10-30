//  Created by Jens Riemschneider on 10/2/11.
//  Copyright 2011 Jens Riemschneider. All rights reserved.
//

#import "LevelSelectionController.h"
#import "Scene.h"
#import "UIScene.h"
#import "BlazeBallView.h"
#import "ModelRegistry.h"
#import "Model.h"
#import "SceneObject.h"
#import "HighscoreRepo.h"
#import "AVFoundation/AVAudioPlayer.h"
#import "AudioRegistry.h"

@implementation LevelSelectionController

@synthesize scene = _scene;
@synthesize uiScene = _uiScene;

- (void)setupAudio {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"blazeballmono64" ofType:@"mp4f"];
    _backgroundMusic =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
    [_backgroundMusic prepareToPlay];
    if (!_view.stopMusic) {
        [_backgroundMusic play];
    }
    _backgroundMusic.numberOfLoops = 100;
    
    _audioRegistry = [[AudioRegistry alloc] init];
}

- (void)moveLevelButtons {
    float current = _currentPos + _currentDrag;
    float diff = current - _prevPos;
    
    int level = 0;
    for (SceneObject *obj in _levelButtons) {
        [_uiScene moveWidget:obj to:CGRectMake(-0.6 + _buttonSpacing * level + current, 0.4, 0.6, 0.6 / _aspect)];
        ++level;
    }
    
    for (SceneObject *obj in _labels) {
        [_uiScene moveWidget:obj by:CGSizeMake(diff, 0)];
    }
    
    _prevPos = _currentPos + _currentDrag;
}

- (void)updateTrialArcadeSelection:(float)diff {
    if (_prevArcadeState != _arcade) {
        float yellowUnselected[] = { 0.8, 0.7, 0, 1 };
        float yellowSelected[] = { 1, 0.8, 0, 1 };
        float whiteUnselected[] = { 0.8, 0.8, 0.8, 1 };
        float whiteSelected[] = { 2, 2, 2, 1 };
        
        if (_arcade) {
            [_uiScene changeColor:_arcadeLabels to:yellowSelected];
            [_uiScene changeColor:_trialLabels to:yellowUnselected];
            _arcadeButton.color = whiteSelected;
            _trialButton.color = whiteUnselected;
            [_uiScene hide:_labels];
            [_uiScene show:_arcadeHighscoreDigits];
        }
        else {
            [_uiScene changeColor:_arcadeLabels to:yellowUnselected];
            [_uiScene changeColor:_trialLabels to:yellowSelected];
            _arcadeButton.color = whiteUnselected;
            _trialButton.color = whiteSelected;
            [_uiScene hide:_arcadeHighscoreDigits];
        }
        
        _prevArcadeState = _arcade;
    }
    
    if (_arcade) {
        _currentPos /= 2;
        _buttonSpacing = (_buttonSpacing - 0.1) / 2 + 0.1;
    }
    else {
        _buttonSpacing = (0.7 - _buttonSpacing) / 2 + _buttonSpacing;
        if (_buttonSpacing > 0.69) {
            _buttonSpacing = 0.7;
            [_uiScene show:_labels];
        }
    }
    [self moveLevelButtons];
}

- (void)setupUiScene {
    [_modelRegistry registerModel:@"sky" withType:[Model class]];

    [_modelRegistry registerModel:@"level01" withType:[Model class]];
    [_modelRegistry registerModel:@"level02" withType:[Model class]];
    [_modelRegistry registerModel:@"level03" withType:[Model class]];
    [_modelRegistry registerModel:@"level04" withType:[Model class]];
    [_modelRegistry registerModel:@"level05" withType:[Model class]];
    [_modelRegistry registerModel:@"level06" withType:[Model class]];
    [_modelRegistry registerModel:@"level07" withType:[Model class]];
    [_modelRegistry registerModel:@"level08" withType:[Model class]];
    [_modelRegistry registerModel:@"level09" withType:[Model class]];
    [_modelRegistry registerModel:@"level10" withType:[Model class]];
    
    [_modelRegistry registerModel:@"0" withType:[Model class]];
    [_modelRegistry registerModel:@"1" withType:[Model class]];
    [_modelRegistry registerModel:@"2" withType:[Model class]];
    [_modelRegistry registerModel:@"3" withType:[Model class]];
    [_modelRegistry registerModel:@"4" withType:[Model class]];
    [_modelRegistry registerModel:@"5" withType:[Model class]];
    [_modelRegistry registerModel:@"6" withType:[Model class]];
    [_modelRegistry registerModel:@"7" withType:[Model class]];
    [_modelRegistry registerModel:@"8" withType:[Model class]];
    [_modelRegistry registerModel:@"9" withType:[Model class]];

    [_modelRegistry registerModel:@"ua" withType:[Model class]];
    [_modelRegistry registerModel:@"ut" withType:[Model class]];

    [_modelRegistry registerModel:@"a" withType:[Model class]];
    [_modelRegistry registerModel:@"c" withType:[Model class]];
    [_modelRegistry registerModel:@"d" withType:[Model class]];
    [_modelRegistry registerModel:@"e" withType:[Model class]];
    [_modelRegistry registerModel:@"i" withType:[Model class]];
    [_modelRegistry registerModel:@"l" withType:[Model class]];
    [_modelRegistry registerModel:@"r" withType:[Model class]];

    [_modelRegistry registerModel:@"medal" withType:[Model class]];
    [_modelRegistry registerModel:@"smallbutton" withType:[Model class]];

    [_modelRegistry registerModel:@"controls" withType:[Model class]];
    [_modelRegistry registerModel:@"fields1" withType:[Model class]];
    [_modelRegistry registerModel:@"fields2" withType:[Model class]];
    [_modelRegistry registerModel:@"modes" withType:[Model class]];
    [_modelRegistry registerModel:@"credits" withType:[Model class]];

    [_modelRegistry registerModel:@"noteson" withType:[Model class]];
    [_modelRegistry registerModel:@"notesoff" withType:[Model class]];

    _uiScene = [[UIScene alloc] initWithRegistry:_modelRegistry];

    float width = _view.frame.size.width;
    float height = _view.frame.size.height;
    _aspect = width / height;
    
    float dx = 24.0 / height;
    float dy = 32.0 / width;

    float yellow[] = { 1, 0.8, 0, 1 };
    float white[] = { 1, 1, 1, 1 };
    float gray[] = { 0.25, 0.25, 0.25, 1 };
    float bronze[] = { 1, 0.8, 0.6, 1 };
    float silver[] = { 0.95, 0.95, 1, 1 };
    float gold[] = { 1, 0.75, 0.3, 1 };
    
    _bronzeScores[0] = 5000;
    _bronzeScores[1] = 5000;
    _bronzeScores[2] = 5000;
    _bronzeScores[3] = 5000;
    _bronzeScores[4] = 5000;
    _bronzeScores[5] = 5000;
    _bronzeScores[6] = 5000;
    _bronzeScores[7] = 5000;
    _bronzeScores[8] = 5000;
    _bronzeScores[9] = 5000;

    _silverScores[0] = 10000;
    _silverScores[1] = 10000;
    _silverScores[2] = 10000;
    _silverScores[3] = 10000;
    _silverScores[4] = 10000;
    _silverScores[5] = 10000;
    _silverScores[6] = 10000;
    _silverScores[7] = 10000;
    _silverScores[8] = 10000;
    _silverScores[9] = 10000;
    
    _goldScores[0] = 20000;
    _goldScores[1] = 20000;
    _goldScores[2] = 20000;
    _goldScores[3] = 20000;
    _goldScores[4] = 20000;
    _goldScores[5] = 20000;
    _goldScores[6] = 20000;
    _goldScores[7] = 20000;
    _goldScores[8] = 20000;
    _goldScores[9] = 20000;

    for (int level = 0; level < 10; ++level) {
        _levelArrangement[level] = level;
    }

    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    NSMutableArray *labels = [[NSMutableArray alloc] init];
    BOOL prevLevelDone = YES;
    for (int level = 0; level < 10; ++level) {
        _levelArrangement[level] = level;
        int highscore = [_view.highscoreRepo getForLevel:level];
        NSString *widgetId = [NSString stringWithFormat:@"level%02i", _levelArrangement[level] + 1];
        float *buttonColor = prevLevelDone ? white : gray;
        [buttons addObject:[_uiScene addWidgetToFront:widgetId at:CGRectMake(-0.6 + 0.7 * level, 0.4, 0.6, 0.6 / _aspect) with:buttonColor]];
        [labels addObjectsFromArray:[_uiScene addDigits:2 value:level + 1 at:CGRectMake(-0.5 + 0.7 * level, 0.125, dx, dy) with:yellow]];
        [labels addObjectsFromArray:[_uiScene addDigits:5 value:abs(highscore) at:CGRectMake(-0.85 + 0.7 * level, 0.125, dx, dy) with:bronze]];
        if (abs(highscore) > _bronzeScores[level]) {
            float *color = highscore > _silverScores[level] ? highscore > _goldScores[level] ? gold : silver : bronze;
            [labels addObject:[_uiScene addWidget:@"medal" at:CGRectMake(-0.4 + 0.7 * level, 0.7, 0.075, 0.1) with:color]];
        }
        
        prevLevelDone = highscore > 0;
    }
    
    for (SceneObject *button in buttons) { button.alpha = 0; }
    for (SceneObject *label in labels) { label.alpha = 0; }
    _fadeButtonsIn = YES;
    
    _buttonSpacing = 0.7;
    _currentPos = 0;
    _prevPos = 0;
    _minPos = 2 - [buttons count] * _buttonSpacing - 0.1;
    
    _levelButtons = buttons;
    _labels = labels;

    _arcadeButtonPos = CGRectMake(-0.7, -0.3, 0.375, 0.25);
    _arcadeButton = [_uiScene addWidget:@"smallbutton" at:_arcadeButtonPos];
    _arcadeLabels = [_uiScene addText:@"Arcade" at:CGRectMake(-0.68 - (dx - 0.01) * 3, -0.31, dx, dy) with:yellow];

    _trialButtonPos = CGRectMake(-0.3, -0.3, 0.375, 0.25);
    _trialButton = [_uiScene addWidget:@"smallbutton" at:_trialButtonPos];
    _trialLabels = [_uiScene addText:@"Trial" at:CGRectMake(-0.28 - (dx - 0.01) * 2.5, -0.31, dx, dy) with:yellow];

    int highscore = [_view.highscoreRepo getForLevel:-1];
    _arcadeHighscoreDigits = [_uiScene addDigits:5 value:abs(highscore) at:CGRectMake(-0.85, 0.125, dx, dy) with:bronze];
    [_uiScene hide:_arcadeHighscoreDigits];

    _arcade = _view.arcade;
    _prevArcadeState = !_arcade;
    
    NSMutableArray *helpers = [[NSMutableArray alloc] init];
    [helpers addObject:[_uiScene addWidget:@"controls" at:CGRectMake(0.47, -0.55, 0.65625, 0.6)]];
    [helpers addObject:[_uiScene addWidget:@"fields1" at:CGRectMake(0.47, -0.55, 0.65625, 0.6)]];
    [helpers addObject:[_uiScene addWidget:@"fields2" at:CGRectMake(0.47, -0.55, 0.65625, 0.6)]];
    [helpers addObject:[_uiScene addWidget:@"modes" at:CGRectMake(0.47, -0.55, 0.65625, 0.6)]];
    [helpers addObject:[_uiScene addWidget:@"credits" at:CGRectMake(0.47, -0.55, 0.65625, 0.6)]];
    _helpers = helpers;

    for (SceneObject *helper in _helpers) { helper.alpha = 0; }

    _notesButtonPos = CGRectMake(-0.8, -0.75, 0.1, 0.2);
    _notesOnButton = [_uiScene addWidget:@"noteson" at:_notesButtonPos with:white hidden:_view.stopMusic];
    _notesOffButton = [_uiScene addWidget:@"notesoff" at:_notesButtonPos with:white hidden:!_view.stopMusic];
    _notesButtonPos.size.width = 0.25;
    _notesButtonPos.size.height = 0.25;

    [_uiScene addWidgetToFront:@"sky" at:CGRectMake(0, 0, 2, 2) with:white];    
}

- (void)setCurrentPos:(float)x andDrag:(float)drag {
    if (x + drag < _minPos) {
        x = _minPos - drag;
    }
    
    if (x + drag > 0) {
        x = -drag;
    }
    
    _currentPos = x;
    _currentDrag = drag;
}

- (void)onPan:(UIPanGestureRecognizer *)recognizer {
    if (_arcade) {
        return;
    }
    
    float height = _view.frame.size.height;

    float movement = [recognizer translationInView:_view].y;
    [self setCurrentPos:_currentPos andDrag:movement / height * 2];
    _currentVelocity = 0;
    if ([recognizer state] == UIGestureRecognizerStateEnded) {
        [self setCurrentPos:_currentPos + _currentDrag andDrag:0];
        _currentVelocity = [recognizer velocityInView:_view].y;
    }
    [self moveLevelButtons];
}

- (void)onTap:(UITapGestureRecognizer *)recognizer {
    float width = _view.frame.size.width;
    float height = _view.frame.size.height;

    CGPoint location = [recognizer locationInView:_view];
    CGPoint pt = CGPointMake(location.y / height * 2 - 1, location.x / width * 2 - 1);
    
    if ([_uiScene rectContainsPoint:&_arcadeButtonPos point:pt]) {
        _arcade = YES;
        [_audioRegistry play:@"click"];
        return;
    }
    
    if ([_uiScene rectContainsPoint:&_trialButtonPos point:pt]) {
        _arcade = NO;
        [_audioRegistry play:@"click"];
        return;
    }
    
    if ([_uiScene rectContainsPoint:&_notesButtonPos point:pt]) {
        _view.stopMusic = !_view.stopMusic;
        _notesOnButton.hidden = _view.stopMusic;
        _notesOffButton.hidden = !_view.stopMusic;
        if (_view.stopMusic) {
            [_backgroundMusic stop];
        }
        else {
            [_backgroundMusic play];
        }
    }
    
    if (pt.y < 0.1 || pt.y > 0.7) {
        return;
    }
    
    _view.arcade = _arcade;
    
    if (_arcade) {
        _view.level = 0;
        _view.scoreFromLastLevel = 0;
        _view.bonusTime = 0;
        _view.bonusJump = 0;
        _pressedButton = [_levelButtons objectAtIndex:0];
        [_audioRegistry play:@"click"];
        return;
    }
    
    float dist = pt.x + 0.9 - _currentPos - _currentDrag;
    int idx = floorf(dist / 0.7);
    if (dist - idx * 0.7 > 0.6) {
        return;
    }
    
    int level = _levelArrangement[idx];
    SceneObject *button = [_levelButtons objectAtIndex:level];
    if (button.color[0] < 1) {
        return;
    }
    
    _view.level = level;
    _view.bronzeScore = _bronzeScores[idx];
    _view.silverScore = _silverScores[idx];
    _view.goldScore = _goldScores[idx];
    _pressedButton = button;
    [_audioRegistry play:@"click"];
}

- (void)setupGestures {
    _panning = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    _tapping = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [_view addGestureRecognizer:_panning];
    [_view addGestureRecognizer:_tapping];
}

- (id)initWithView:(BlazeBallView *)view andRegistry:(ModelRegistry *)modelRegistry {
    self = [super init];
    if (self) {
        _view = view;
        _modelRegistry = modelRegistry;
        [_modelRegistry retain];
        [self setupAudio];
        [self setupUiScene];
        [self setupGestures];
    }
    
    return self;
}

- (void)dealloc {
    [_view removeGestureRecognizer:_panning];
    [_view removeGestureRecognizer:_tapping];
    
    [_backgroundMusic release];
    [_scene release];
    [_uiScene release];
    [_modelRegistry release];
    [_levelButtons release];
    [_panning release];
    [_tapping release];
    [_trialLabels release];
    [_arcadeLabels release];
    [_arcadeHighscoreDigits release];
    [_audioRegistry release];
    [_helpers release];
    [super dealloc];
}

- (void)updateVelocity:(double)diff {
    if (abs(_currentVelocity) > 1) {
        float dist = _currentVelocity * diff / 200;
        _currentVelocity *= 0.8;
        [self setCurrentPos:_currentPos + dist andDrag:0];
        [self moveLevelButtons];
    }
}

- (void)updatePressedButton:(double)diff {
    if (_pressedButton) {
        _backgroundMusic.volume -= diff;
        if (_pressedButtonState == 0) {
            _pressedButton.color[0] += diff * 3;
            _pressedButton.color[1] += diff * 3;
            _pressedButton.color[2] += diff * 3;
            if (_pressedButton.color[0] > 2) {
                _pressedButtonState = 1;
            }
        }
        else if (_pressedButtonState == 1) {
            _pressedButton.color[0] -= diff * 3;
            _pressedButton.color[1] -= diff * 3;
            _pressedButton.color[2] -= diff * 3;
            if (_pressedButton.color[0] < 1) {
                _pressedButtonState = 2;
            }
        }
        else if (_pressedButtonState == 2) {
            if ([_uiScene fadeOut:_levelButtons by:2 * diff]) {
                _pressedButtonState = 3;
            }
            [_uiScene fadeOut:_labels by: 2 * diff];
            [_uiScene fadeOut:_arcadeLabels by: 2 * diff];
            [_uiScene fadeOut:_trialLabels by: 2 * diff];
            [_uiScene fadeOut:_arcadeHighscoreDigits by: 2 * diff];
            [_uiScene fadeOut:_helpers by: 6 * diff];
            _arcadeButton.alpha -= 2 * diff;
            _trialButton.alpha -= 2 * diff;
            _notesOffButton.alpha -= 2 * diff;
            _notesOnButton.alpha -= 2 * diff;
        }
        else if (_pressedButtonState == 3) {
            _switchController = YES;
            _pressedButtonState = 4;
        }
    }
}

- (void)updateButtonFadeIn:(double)diff {
    if (_fadeButtonsIn) {
        _fadeButtonsIn = ![_uiScene fadeIn:_levelButtons by:2 * diff];
        [_uiScene fadeIn:_labels by:2 * diff];
    }
}

- (void)updateHelpers:(double)diff {
    if (_pressedButton) {
        return;
    }
    
    SceneObject *helper = [_helpers objectAtIndex:_currentHelper];
    if (_fadeHelperOut) {
        helper.alpha -= diff / 2;
        if (helper.alpha <= 0) {
            _fadeHelperOut = NO;
            _currentHelper = (_currentHelper + 1) % [_helpers count];
        }
    }
    else {
        helper.alpha += diff;
        if (helper.alpha >= 3) {
            _fadeHelperOut = YES;
        }
    } 
}

- (void)update:(double)currentTime {
    if (_lastTime == 0) {
        _lastTime = currentTime;
        return;
    }
    
    double diff = currentTime - _lastTime;

    [self updateVelocity:diff];
    [self updatePressedButton:diff];
    [self updateButtonFadeIn:diff];
    [self updateTrialArcadeSelection:diff];
    [self updateHelpers:diff];
    
    _lastTime = currentTime;
    
    // Must be last
    if (_switchController) {
        [_view switchMode:MODE_LEVEL];
    }
}

- (void)touchBegan:(UITouch *)touch pos:(CGPoint)touchPt at:(double)timestamp {
}

- (void)touchMove:(UITouch *)touch pos:(CGPoint)touchPt at:(double)timestamp {
}

- (void)touchEnd:(UITouch *)touch pos:(CGPoint)touchPt at:(double)timestamp {
}

- (void)touchCancelled:(UITouch *)touch pos:(CGPoint)touchPt at:(double)timestamp {
}

- (void)accelerate:(UIAcceleration *)acceleration {
}

@end
