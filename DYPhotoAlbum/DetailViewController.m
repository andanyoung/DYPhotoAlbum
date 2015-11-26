//
//  ViewController.m
//  DYPhotoAlbum
//
//  Created by tarena on 15/11/17.
//  Copyright © 2015年 ady. All rights reserved.
//

#import "DetailViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <assert.h>
#import "iCarousel.h"
#import "NirKxMenu.h"

@interface DetailViewController ()<iCarouselDelegate, iCarouselDataSource>
@property(nonatomic,strong) iCarousel *ic;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) UIImageView *backGroungImage;
/** 相册信息 */
@property (nonatomic, strong) NSMutableArray *imageURLs;
@property (nonatomic, strong) NSMutableArray *images;
@end

@implementation DetailViewController
- (NSMutableArray *)images{
    if (!_images) {
        _images = [[NSMutableArray alloc]initWithCapacity:20];
        
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
          //  NSInteger groupNumber = [group numberOfAssets];
            
            if ([groupName isEqualToString:_albumType]) {
                NSLog(@"group:%@",group);
    
                    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if (result) {
                            NSLog(@"result:%@",result);
                            NSString *resultType = [result valueForProperty:ALAssetPropertyType];
                            if ([resultType isEqualToString:ALAssetTypePhoto]) {
                                //获取资源图片的详细资源信息
                                ALAssetRepresentation* representation = [result defaultRepresentation];
                                
                                
                                UIImage *image = [UIImage imageWithCGImage:[representation fullResolutionImage]];
                                [_images addObject:image];
                                if (index>10) {
                                    [_ic reloadData];
                                    *stop = YES;
                                }
                            }
                        }else{
                            [_ic reloadData];
                        }
                    }
                     ];
                }
            

        } failureBlock:nil
         ];
        
        
    }
    return _images;
}
- (iCarousel *)ic{
    if (!_ic) {
        _ic = [iCarousel new];
        //就是仿写的CollectionView
        _ic.delegate = self;
        _ic.dataSource = self;
        //修改3D显示模式, type是枚举类型，数值0 ~ 11
        _ic.type = 3;
        //自动展示, 0表示不滚动 越大滚动的越快
        _ic.autoscroll = 0.1;
        //改变为竖向展示
        //        _ic.vertical = NO;
        
        // 改为翻页模式
        _ic.pagingEnabled = NO;
        //滚动速度
        _ic.scrollSpeed = 2;
    }
    return _ic;
}

- (UIImageView *)backGroungImage{
    if (!_backGroungImage) {
        _backGroungImage = [UIImageView new];
        _backGroungImage.contentMode = 2;
        _backGroungImage.clipsToBounds = YES;
        [self.view addSubview:_backGroungImage];
        UIVisualEffectView *effectView =  [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        effectView.frame = self.view.frame;
        effectView.alpha = 0.5;
        [_backGroungImage insertSubview:effectView atIndex:1];
    }
    return _backGroungImage;
}
- (ALAssetsLibrary *)assetsLibrary{
    if (!_assetsLibrary) {
        _assetsLibrary = [ALAssetsLibrary new];
    }
    return _assetsLibrary;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.backGroungImage.frame = self.view.frame;
    [self.view addSubview:self.ic];
    self.ic.frame = self.view.bounds;
    self.title = _albumType;
    
}

#pragma mark - iCarousel
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    
    return self.images.count;
}

//添加循环滚动
- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value{
    if (option == iCarouselOptionWrap) {
        return YES; //type0的默认循环滚动模式是否
    }
    // 修改缝隙
    if (option == iCarouselOptionSpacing) {
        return value ;
    }
    // 取消后背的显示
    if (option == iCarouselOptionShowBackfaces) {
        return YES;
    }
    
    return value;
}

//问：每个Cell什么样
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(nullable UIView *)view{
    if (!view) {
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        UIImageView *imageView = [UIImageView new];
        imageView.tag = 100;
        [view addSubview:imageView];
        // CGFloat imageheight = view.bounds.size.height - 100;
        CGFloat imageWidth = view.bounds.size.width ;
        imageView.frame = CGRectMake( 0,0,imageWidth, imageWidth);
        imageView.center = view.center;
        
        imageView.contentMode = 2;
        imageView.clipsToBounds = YES;
    }
    UIImageView *imageView = (UIImageView *)[view viewWithTag:100];
    imageView.image = self.images[index];
    
    if (index == 0) {
         self.backGroungImage.image = self.images[index];
    }
   

    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    NSLog(@"选择了第%ld张", index);
}





@end
