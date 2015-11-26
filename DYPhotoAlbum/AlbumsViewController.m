//
//  AlbumsViewController.m
//  DYPhotoAlbum
//
//  Created by tarena on 15/11/18.
//  Copyright © 2015年 ady. All rights reserved.
//

#import "AlbumsViewController.h"
#import "DetailViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DYGroup.h"

@interface AlbumsViewController ()<UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSMutableArray<DYGroup *> *albums;
@end

@implementation AlbumsViewController

- (NSMutableArray *)albums{
    if (!_albums) {
        _albums = [NSMutableArray new];
        
        //获取相册信息
        ALAssetsLibrary *assetsLibrary = [ALAssetsLibrary new];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            NSLog(@"currentThread:%@",[NSThread currentThread]);
            NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
            NSInteger groupNumber = [group numberOfAssets];
            NSLog(@"groupNumber:%ld",groupNumber);
            NSLog(@"groupName:%@",groupName);
         
            if (group) {
                NSLog(@"group:%@",group);
                DYGroup *albumGroup = [DYGroup new];
                albumGroup.groupName = groupName;
                albumGroup.count = [group numberOfAssets];
                
                
                //When the enumeration is done, enumerationBlock is invoked with group set to nil
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        NSLog(@"result:%@",result);
                        NSString *resultType = [result valueForProperty:ALAssetPropertyType];
                        if ([resultType isEqualToString:ALAssetTypePhoto]) {
                            //获取资源图片的详细资源信息
                            ALAssetRepresentation* representation = [result defaultRepresentation];
                            
                           
                            //[_imageURLs addObject:[representation fullResolutionImage] ];
                            albumGroup.iconView = [UIImage imageWithCGImage: result.thumbnail];
                            albumGroup.iconView = [UIImage imageWithCGImage: [representation fullResolutionImage]];
                            *stop = YES;
                        }
                    }
                }];
                [_albums addObject:albumGroup];
            }else{
                //坑爹的，这是主线程异步要刷新。。。
                [self.collectionView reloadData];
            }
            
            NSLog(@"%@",group);
        } failureBlock:^(NSError *error) {
            NSLog(@"读取相册失败");
        }];
    }
    return _albums;
}

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
   
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"numberOfItemsInSection:%ld",self.albums.count);
    return self.albums.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    DYGroup *group = self.albums[indexPath.row];
    // Configure the cell
    UIImageView *imageView = [cell viewWithTag:100];
    UILabel *label = [cell viewWithTag:200];
    if (imageView == nil) {
        imageView = [UIImageView new];
        [cell.contentView addSubview:imageView];
        imageView.frame = CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
        imageView.tag = 100;
        imageView.contentMode = 0;
        
        NSLog(@"%@",NSStringFromCGRect(cell.contentView.frame));
    }
    if (label == nil) {
        label = [UILabel new];
        [cell.contentView addSubview:label];
        label.frame =  CGRectMake(0, cell.contentView.frame.size.height -30, cell.contentView.frame.size.width,30);
        label.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.7];
    }
    label.text = group.groupName;
    imageView.image = group.iconView;
    cell.backgroundColor = [UIColor redColor];
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(130, 130);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(15, 10, 5,10);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    DetailViewController *vc =  [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"detail"];
    vc.albumType = self.albums[indexPath.row].groupName;
    vc.imageCount = self.albums[indexPath.row].count;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
