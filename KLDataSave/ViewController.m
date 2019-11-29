//
//  ViewController.m
//  KLDataSave
//
//  Created by WKL on 2019/11/26.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "ViewController.h"
#import "KLWriteToFileManger.h"
#import "KLCoreDataManager.h"
#import "KLUserModel.h"
#import "KLCoreDataManager.h"
#import "Person+CoreDataProperties.h"
#import "Contacts+CoreDataProperties.h"
#import "Address+CoreDataProperties.h"
#import "Animal+CoreDataProperties.h"



@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>{
    
    NSArray *_rTitles;
}

@property(nonatomic,strong)UITableView *rTableView;

@property(nonatomic,strong)UILabel *rDetailLabel;

/**
 管理数据的对象
 */
@property (nonatomic, strong) NSManagedObjectContext *rContext;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"数据存储";
    
    _rTitles = @[@"简单对象写入",@"model数据写入",@"coreData 创建数据库",@"coreData 添加数据",@"删除数据",@"修改数据",@"查询数据"] ;
    
    [self.view addSubview:self.rTableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _rTitles.count ;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * const cellIdentify = @"cellIdentify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
        
    }
    
    cell.textLabel.text = _rTitles[indexPath.row] ;
    return cell ;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        
        [self pvt_saveSimpleData];
    }else if (indexPath.row == 1){
        [self pvt_saveModel];
    }else if (indexPath.row == 2){
        [self pvt_createDB];
    }else if (indexPath.row == 3){
        
        //        if (!self.rContext) {
        //            [self pvt_createDB];
        //            return ;
        //        }
        [self pvt_addData];
    }else if (indexPath.row == 4){
        if (!self.rContext) {
            [self pvt_createDB];
            return ;
        }
        [self  pvt_deleteData ] ;
    }else if (indexPath.row == 5){
        //        if (!self.rContext) {
        //            [self pvt_createDB];
        //            return ;
        //        }
        [self  pvt_changeData ] ;
    }else if (indexPath.row == 6){
        if (!self.rContext) {
            [self pvt_createDB];
            return ;
        }
        [self pvt_searchData];
    }
    
    
}

-(void)pvt_createDB{
    
    NSURL *pathURL = [[NSBundle mainBundle]URLForResource:@"KLCoreModel" withExtension:@"momd"];;
    NSManagedObjectModel *mode = [[NSManagedObjectModel alloc]initWithContentsOfURL:pathURL]; ;
    
    NSPersistentStoreCoordinator *coord = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:mode];
    
    NSString *dpPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:@"/userInfo.sqlite"];
    NSURL *url = [NSURL fileURLWithPath:dpPath];
    NSError *error;
    [coord addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error];
    
    if (error == nil) {
        NSLog(@"数据库添加成功");
    } else {
        NSLog(@"数据库添加失败%@",error);
    }
    
    _rContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType] ;
    _rContext.persistentStoreCoordinator = coord ;
}

-(void)pvt_addData{
    
    /*
     for (int i= 0;i< 10 ; i++){
     Userinfo *rperson = [NSEntityDescription insertNewObjectForEntityForName:@"Userinfo" inManagedObjectContext:self.rContext];
     rperson.rName = [NSString stringWithFormat:@"ray%d",i];
     rperson.rAge = 18 + i;
     }
     NSError *error;
     BOOL isSuccess = [self.rContext save:&error];
     isSuccess == YES ? NSLog(@"添加成功") : NSLog(@"添加失败");
     */
    
    
    NSMutableArray *personArray = [NSMutableArray array] ;
    for (int i= 0;i< 3 ; i++){
        Person *rperson = [KLCoreDataManager getTableWithEntityName:@"Person"];
        rperson.rName = [NSString stringWithFormat:@"rrr %d",i];
        rperson.rAge = 18 + i;
        
        Address *add = [KLCoreDataManager getTableWithEntityName:@"Address"];
        add.country = @"美国";
        add.row = [NSString stringWithFormat:@"row %d",i];
        add.city = [NSString stringWithFormat:@"%@city%d",rperson.rName,i];
        [rperson addAddressesObject:add];
        
        [personArray addObject:rperson];
    }
    
    for (int i= 0;i< 6 ; i++){
        Animal *rperson = [KLCoreDataManager getTableWithEntityName:@"Animal"];
        rperson.rAge =  arc4random()%100000 + 1363;
        rperson.color =  @"red";
        rperson.rName = [NSString stringWithFormat:@"animal%d",i];
        
        
    }
    
    for (int i= 0;i< 3 ; i++){
        Contacts *rperson = [KLCoreDataManager getTableWithEntityName:@"Contacts"];
        rperson.rTel =  arc4random()%100000 + 1363;
        rperson.owner = personArray[i%3];
        rperson.rName = [NSString stringWithFormat:@"%@ %d",rperson.owner.rName,i];
        
        
    }
    
    
    for (int i= 0;i< 6 ; i++){
        Address *rAdd = [KLCoreDataManager getTableWithEntityName:@"Address"];
        rAdd.city = [NSString stringWithFormat:@"city %d",i];
        rAdd.country =  @"中国";
        rAdd.row = [NSString stringWithFormat:@"row %d",i];
        rAdd.objects = [NSSet setWithArray:personArray] ;
    }
    
    
    [KLCoreDataManager save] ;
    
}

-(void)pvt_deleteData{
    
    /*
     NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Person"] ;
     
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rAge=%d",20] ;
     fetchRequest.predicate = predicate ;
     NSError *error;
     NSArray *results = [self.rContext executeFetchRequest:fetchRequest error:&error] ;
     if (results) {
     for (Userinfo *user in results) {
     [self.rContext deleteObject:user];
     }
     
     BOOL isSuccess = [self.rContext save:&error];
     isSuccess == YES ? NSLog(@"删除成功") : NSLog(@"删除失败");
     }
     */
    
    [KLCoreDataManager deleteByEntityName:@"Person" withAttribute:@"rAge" withMaching:@"20"];
    
    
}

-(void)pvt_changeData{
    
    //    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Userinfo"] ;
    //
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rAge=%d",18] ;
    //    fetchRequest.predicate = predicate ;
    //    NSError *error;
    //    NSArray *results = [self.rContext executeFetchRequest:fetchRequest error:&error] ;
    //    if (results) {
    //        for (Userinfo *user in results) {
    //            user.rAge = 11 ;
    //
    //        }
    //
    //        BOOL isSuccess = [self.rContext save:&error];
    //        isSuccess == YES ? NSLog(@"修改成功") : NSLog(@"修改失败");
    //    }
    
    /*
     NSArray *array = [KLCoreDataManager selectByEntityName:NSStringFromClass([Userinfo class])
     withAttribute:nil
     
     withMaching:nil
     sortingBy:@"rAge"
     isAscending:YES];
     
     if (array.count) {
     
     Userinfo  *model = array.firstObject;
     model.rName = @"爱听话的孩子";
     
     [KLCoreDataManager updateManagedObject:model] ;
     
     }
     
     */
    
    NSArray *array = [KLCoreDataManager selectByEntityName:NSStringFromClass([Person class])
                                             withAttribute:nil
                      
                                               withMaching:nil
                                                 sortingBy:@"rAge"
                                               isAscending:YES];
    
    NSInteger index = 0 ;
    for (Person *stu in array) {
        
        stu.rSex = index%2;
        index ++ ;
        
        [KLCoreDataManager updateManagedObject:stu] ;
    }
    
    
}
-(void)pvt_searchData{
    
    
    /*
     NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Address"] ;
     
     NSError *error;
     NSArray *results = [self.rContext executeFetchRequest:fetchRequest error:&error] ;
     if (results) {
     for (Address *user in results) {
     NSLog(@"名字是:%@ 年龄是:%lld",user.objects,user.city);
     }
     
     }
     
     */
    
    NSArray *results = [KLCoreDataManager selectByEntityName:@"Address" withAttribute:nil withMaching:@"rrr 2city2" sortingBy:@"city" isAscending:YES];
    for (Address *user in results) {
        NSLog(@"地区人数:%lu 地区名是:%@",(unsigned long)user.objects.count,user.city);
    }
    
}



-(void)pvt_saveModel {
    
    KLUserModel *model = [KLUserModel new] ;
    model.rName = @"the name";
    model.rAge = 19;
    
    [[KLWriteToFileManger shareManager]archiveObject:model prefix:@"/user.text"];
    
    
}

-(void)pvt_saveSimpleData{
    
    
    NSString *textStr = @"dddd 这是新的string 写入" ;
    
    //     3.1第一个参数 路径
    //    3.2第二个参数 是否进行线性操作（YES保证发生意外时有中转文件来保存信息 直至写入完成 但是损耗大. NO的时候写入速度快 但是没有安全保障）
    //    3.3第三个参数 编码方式
    //    3.4第四个参数 错误对象
    
    //    [textStr writeToFile:[self getDocumentPathByAppendPath:@"/string.text"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [[KLWriteToFileManger shareManager] writeToFiled:@"/string.text" data:textStr] ;
    
    //    取
    //    NSString *contentString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //    NSLog(@"%@",contentString);
    
    
    //    NSArray 写入
    NSArray *array = [NSArray arrayWithObjects:@"Lily",@"Yucui",@"Star",@"Ling",@"Wenqi",@"Yangyang", nil];
    
    //    [array writeToFile:[self getDocumentPathByAppendPath:@"/array.text"] atomically:YES];
    [[KLWriteToFileManger shareManager] writeToFiled:@"/array.text" data:array];
    
    //    取
    //    NSArray *readArray = [NSArray arrayWithContentsOfFile:path];
    
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"SB",@"1",@"38",@"2",@"孩子",@"3",@{@"name":@"xx",@"age":@(19)},@"dict1", nil];
    
    [[KLWriteToFileManger shareManager] writeToFiled:@"/dict.text" data:dict];
    
    //    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    
    //    NSData 写入
    
    NSData *data = [textStr dataUsingEncoding:NSUTF8StringEncoding] ;
    [[KLWriteToFileManger shareManager] writeToFiled:@"/data.text" data:data];
    //    取
    //    NSString *ss = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] ;
    
    
}



-(UITableView*)rTableView {
    if (!_rTableView) {
        _rTableView = [UITableView new] ;
        _rTableView.delegate = self ;
        _rTableView.dataSource = self ;
        _rTableView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
        //        _rTableView.contentInsetAdjustmentBehavior
    }
    return _rTableView ;
}


@end
