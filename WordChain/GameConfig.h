//
//  GameConfig.h
//  WordChain
//
//  Created by Bryan Dunbar on 8/23/11.
//  Copyright Great American Insurance 2011. All rights reserved.
//

#ifndef __GAME_CONFIG_H
#define __GAME_CONFIG_H

//
// Supported Autorotations:
//		None,
//		UIViewController,
//		CCDirector
//
#define kGameAutorotationNone 0
#define kGameAutorotationCCDirector 1
#define kGameAutorotationUIViewController 2

//
// Define here the type of autorotation that you want for your game
//
#define GAME_AUTOROTATION kGameAutorotationNone


#define ORIENTATION kCCDeviceOrientationPortrait
//#define ORIENTATION kCCDeviceOrientationLandscapeLeft
#endif // __GAME_CONFIG_H