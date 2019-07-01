//
//  ViewController.m
//  Mars Metro Connect
//
//  Created by Murali Krishnan Govindarajulu on 10/24/15.
//  Copyright © 2015 EasyMetro. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
//
// graph
//
//#import "APGraph.h"
//#import "APGraphNode.h"
//#import "APGraphEdge.h"
//#import "APGraphRoute.h"
//#import "APGraphRouteStep.h"
//#import "APGraphPoint.h"
//#import "APGraphPointPixel.h"

#import "EasyMetroGraph.h"

#import "MetroiPhoneOutputViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIPickerView *fromPicker;
@property (strong, nonatomic) IBOutlet UIPickerView *toPicker;
@property (strong, nonatomic) IBOutlet UITextView *outputTextView;
@property (strong, nonatomic) IBOutlet UIButton *btnCalculate;
@property (strong, nonatomic) IBOutlet UILabel *showOutputLabel;
@property (strong,nonatomic) EasyMetroGraph *graph;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *pickerViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topickerViewHeightConstraint;
@end

@implementation ViewController
{
    NSMutableString *routeString;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.fromPicker.delegate=self;
    self.toPicker.delegate=self;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        _outputTextView.hidden=YES;
    }
    _showOutputLabel.hidden=YES;
    [self contructGraph];
   
}

// +---------------------------------------------------------------------------+
#pragma mark - UIPickerView
// +---------------------------------------------------------------------------+


- (NSInteger)  pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component { return [ self metroNames ].count; }
- (NSInteger)  numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 1; }
- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component { 	return [self metroNames][row]; }

// +---------------------------------------------------------------------------+
#pragma mark - Station Names
// +---------------------------------------------------------------------------+


- (NSArray*) metroNames
{
    NSArray *names = @[
                       @"North Park", @"Sheldon Street", @"Sesto Marelli",
                       @"Greenland", @"City Centre", @"Stadium House",
                       @"Green House", @"Green Cross", @"South Pole",
                       @"South Park", @"East End", @"Foot Stand", @"Football stadium",
                       @"Peter park", @"Maximus", @"Rocky street", @"Boxers street",
                       @"Boxing avenue", @"West End", @"Gotham Street", @"Batman Street",
                       @"Jokers Street", @"Hawkins Street",
                       @"Da vinci lane", @"Newton bath tub", @"Einstein lane", @"Neo lane", @"Matrix stand",
                       @"Keymakers lane", @"Oracle lane", @"Cypher lane", @"Smith lane",
                       @"Morpheus lane", @"Trinity lane", @"Orange street", @"Silk board",
                       @"Snake park", @"Little street", @"Cricket Grounds"
                       ];
    
    NSArray *sortedArray =
    [names sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b){
        return [a compare:b];
    }];
    
    return sortedArray;
}

- (IBAction)calculateShortestPath:(id)sender {
    
    NSString *from = [[self metroNames] objectAtIndex:[_fromPicker selectedRowInComponent:0]];
    NSString *to   = [[self metroNames] objectAtIndex:[_toPicker   selectedRowInComponent:0]];
    [ self fetchRouteDetails:from to:to ];
}

- (NSDictionary*) loadJson
{
    NSString *fPath = [[NSBundle mainBundle] pathForResource:@"MetroMarsCity" ofType:@"json"];
    NSData    *data = [NSData dataWithContentsOfFile:fPath];
    return [NSJSONSerialization JSONObjectWithData: data
                                     options: NSJSONReadingMutableContainers
                                       error:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)contructGraph
{
    _graph = [[EasyMetroGraph alloc] init];
    
    NSDictionary *jDict = [self loadJson];
    
    NSArray *itemArr = (NSArray *)[jDict valueForKey:@"marsCities"];
    int tot = (int)itemArr.count;
    
    for ( int i=0; i<tot; i++ )
    {
        NSDictionary *stopsList  = [jDict valueForKey:@"marsCities"][i];
        NSString *stopId       = [ stopsList valueForKey:@"id" ];
        NSString *links     = [ stopsList valueForKey:@"links"];
        NSArray *linksArray = [ links componentsSeparatedByString:@"," ];
        NSString *srouteLinks     = [ stopsList valueForKey:@"routeLink"];
        NSArray *srouteLinksArray = [ srouteLinks componentsSeparatedByString:@"," ];
        
        for ( NSString* lnk in linksArray )
        {
            NSString		*currName       = [[[ jDict valueForKey:@"marsCities"] objectAtIndex:[stopId intValue] ] valueForKey:@"name"];
            NSString		*linkedName     = [[[ jDict valueForKey:@"marsCities"] objectAtIndex:[lnk intValue] ] valueForKey:@"name"];
            NSString *lnkrouteLinks     = [ [[ jDict valueForKey:@"marsCities"] objectAtIndex:[lnk intValue] ] valueForKey:@"routeLink"];
            NSArray *lnkrouteLinksArray = [ lnkrouteLinks componentsSeparatedByString:@"," ];
            
            EasyMetroGraphNodePoint *currentNodePoint   = [[EasyMetroGraphNodePoint alloc] init];
            currentNodePoint.identifier           = currName;
            currentNodePoint.linkRoutes           = srouteLinksArray;
            
            EasyMetroGraphNodePoint *linkedNodePoint   = [[EasyMetroGraphNodePoint alloc] init];
            linkedNodePoint.linkRoutes           = lnkrouteLinksArray;
            linkedNodePoint.identifier           = linkedName;
            
            EasyMetroGraphNode *currNode   = [ EasyMetroGraphNode nodeWithPoint:currentNodePoint ];
            EasyMetroGraphNode *linkedNode = [ EasyMetroGraphNode nodeWithPoint:linkedNodePoint ];
            
            
            int weigth            = [[[[ jDict valueForKey:@"marsCities"] objectAtIndex:[stopId intValue] ] valueForKey:@"weight"] intValue];
            EasyMetroGraphEdge *currentEdge = [ EasyMetroGraphEdge edgeWithName:currName andWeight:[NSNumber numberWithInt:weigth]];
            [_graph addEdgeBetweenNodes:currentEdge fromNode:currNode toNode:linkedNode];
            [_graph addEdgeBetweenNodes:currentEdge fromNode:linkedNode toNode:currNode];
        }
    }
}

- (void) fetchRouteDetails:(NSString*)from to:(NSString*)to
{
    EasyMetroGraphNode *fromNode  = [ EasyMetroGraphNode nodeWithIdentifier:from ];
    EasyMetroGraphNode *toNode  = [ EasyMetroGraphNode nodeWithIdentifier:to ];
    EasyMetroGraphPath *route			= [_graph getRouteFromStop:fromNode toStop:toNode];
    [self calculatePriceForRoute:route];
}

-(void)calculatePriceForRoute:(EasyMetroGraphPath *)path
{
    int ticketPrice = (int)(path.pathWays.count -1);
    int totalTimeRequired = ticketPrice*5;
    routeString = [NSMutableString string];
    [routeString appendString:@"Start from "];
    for (int i=0; i<path.pathWays.count; i++) {
        EasyMetroGraphPathWay *currentStep = path.pathWays[i];
        EasyMetroGraphNodePoint *routePoint = (EasyMetroGraphNodePoint*)((EasyMetroGraphNode*)[_graph.nodes valueForKey:currentStep.node.point.identifier]).point;
        NSArray *currentlinkRoutes = routePoint.linkRoutes;
       
        if (i==0) {
            if (currentlinkRoutes.count>1  && i<path.pathWays.count-1) {
                EasyMetroGraphPathWay *nextStep = path.pathWays[i+1];
                EasyMetroGraphNodePoint *nextroutePoint = (EasyMetroGraphNodePoint*)((EasyMetroGraphNode*)[_graph.nodes valueForKey:nextStep.node.point.identifier]).point;
                NSArray *nextlinkRoutes = nextroutePoint.linkRoutes;
                [routeString appendFormat:@"%@ at %@ line ", routePoint.identifier,nextlinkRoutes[0]];
            }
            else
            {
                [routeString appendFormat:@"%@ at %@ line  ", routePoint.identifier,currentlinkRoutes[0]];
            }
        }
        else if (currentlinkRoutes.count>1 && i>0 && i<path.pathWays.count-1) {
            EasyMetroGraphPathWay *prevStep = path.pathWays[i-1];
            EasyMetroGraphNodePoint *prevroutePoint = (EasyMetroGraphNodePoint*)((EasyMetroGraphNode*)[_graph.nodes valueForKey:prevStep.node.point.identifier]).point;
            NSArray *prevlinkRoutes = prevroutePoint.linkRoutes;
            
            EasyMetroGraphPathWay *nextStep = path.pathWays[i+1];
            
                EasyMetroGraphNodePoint *nextroutePoint = (EasyMetroGraphNodePoint*)((EasyMetroGraphNode*)[_graph.nodes valueForKey:nextStep.node.point.identifier]).point;
            
            NSArray *nextlinkRoutes = nextroutePoint.linkRoutes;
            if (![[prevlinkRoutes objectAtIndex:0] isEqualToString:[nextlinkRoutes objectAtIndex:0]]) {
                ticketPrice++;
                [routeString appendFormat:@"\n\nSwitch to %@ line at %@ \n\nThen move through",nextlinkRoutes[0],routePoint.identifier];
            }
            else
            {
                [routeString appendFormat:@" -> %@",routePoint.identifier];
            }
        }
        else
        {
            
            [routeString appendFormat:@" -> %@",routePoint.identifier];
            
        }
    }
    [routeString appendFormat:@"\n\nThe trip will take %d minutes. \n\nPlease pay a ticket price of $ %d", totalTimeRequired,ticketPrice];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [self performSegueWithIdentifier:@"showOutputScreen" sender:nil];
    }
    else
    {
        _outputTextView.text=routeString;
        _showOutputLabel.hidden=NO;
        [_outputTextView setFont:[UIFont systemFontOfSize:20]];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    MetroiPhoneOutputViewController *mp = [segue destinationViewController];
    mp.routeDetails=routeString;
}

@end
