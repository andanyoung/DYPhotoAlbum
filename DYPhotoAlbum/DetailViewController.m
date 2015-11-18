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


@interface DetailViewController ()<iCarouselDelegate, iCarouselDataSource>
@property(nonatomic,strong) iCarousel *ic;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
/** 相册信息 */
@property (nonatomic, strong) NSMutableArray *imageURLs;

@end

@implementation DetailViewController

- (iCarousel *)ic{
    if (!_ic) {
        _ic = [iCarousel new];
        //就是仿写的CollectionView
        _ic.delegate = self;
        _ic.dataSource = self;
        //修改3D显示模式, type是枚举类型，数值0 ~ 11
        _ic.type = 1;
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


- (NSMutableArray *)imageURLs {
    if(_imageURLs == nil) {
        _imageURLs = [[NSMutableArray alloc] init];
        
    
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
           NSLog(@"currentThread:%@",[NSThread currentThread]);
            NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
            NSInteger groupNumber = [group numberOfAssets];
            NSLog(@"groupNumber:%ld",groupNumber);
            if ([groupName isEqualToString:_albumType]) {
                 NSLog(@"group:%@",group);
                
                //When the enumeration is done, enumerationBlock is invoked with group set to nil
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                         NSLog(@"result:%@",result);
                       NSString *resultType = [result valueForProperty:ALAssetPropertyType];
                        if ([resultType isEqualToString:ALAssetTypePhoto]) {
                            //获取资源图片的详细资源信息
                            ALAssetRepresentation* representation = [result defaultRepresentation];
                            
                            //[_imageURLs addObject:result.thumbnail];
                            [_imageURLs addObject:[representation fullResolutionImage] ];
                        }
                    }
                }];
                
            }else{
                //坑爹的，这是主线程异步要刷新。。。
                [self.ic reloadData];
            }
            
            NSLog(@"%@",group);
        } failureBlock:^(NSError *error) {
            NSLog(@"读取相册失败");
        }];
    }
    return _imageURLs;
}
- (ALAssetsLibrary *)assetsLibrary{
    if (!_assetsLibrary) {
        _assetsLibrary = [ALAssetsLibrary new];
    }
    return _assetsLibrary;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.ic];
    self.ic.frame = self.view.bounds;
    self.title = _albumType;
   
 
}

#pragma mark - iCarousel
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
   
    return self.imageURLs.count;
}

//添加循环滚动
- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value{
    if (option == iCarouselOptionWrap) {
        return YES; //type0的默认循环滚动模式是否
    }
    // 修改缝隙
    if (option == iCarouselOptionSpacing) {
        return value * 1.5;
    }
    // 取消后背的显示
    if (option == iCarouselOptionShowBackfaces) {
        return NO;
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
        CGFloat imageheight = view.bounds.size.height - 100;
        CGFloat imageWidth = view.bounds.size.width ;
        imageView.frame = CGRectMake( 0,view.bounds.size.height - imageheight,imageWidth, imageheight);
        imageView.contentMode = 1;
        //imageView.clipsToBounds = YES;
    }
     UIImageView *imageView = (UIImageView *)[view viewWithTag:100];
    if (self.imageURLs.count>1) {
        imageView.image = [UIImage imageWithCGImage: (__bridge CGImageRef _Nonnull)(self.imageURLs[index])];
    }
    

    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    NSLog(@"选择了第%ld张", index);
}





@end
