//
//  DYAlbum.h
//  DYPhotoAlbum
//
//  Created by tarena on 15/11/18.
//  Copyright © 2015年 ady. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DYGroup : NSObject

@property (nonatomic, strong) NSString *groupName;
@property (nonatomic) NSInteger count;
@property (nonatomic,strong) UIImage *iconView;
@property (nonatomic, strong) NSString *type;

@end
