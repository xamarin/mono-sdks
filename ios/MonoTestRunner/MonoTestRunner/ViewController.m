//
//  ViewController.m
//  MonoTestRunner
//
//  Created by Rodrigo Kumpera on 3/30/17.
//  Copyright © 2017 Rodrigo Kumpera. All rights reserved.
//

#import "ViewController.h"
#include "runtime-bootstrap.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    init_runtime();
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
