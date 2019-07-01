//
//  EasyMetroGraph.h
//  Mars Metro Connect
//
//  Created by Murali Krishnan Govindarajulu on 10/26/15.
//  Copyright © 2015 EasyMetro. All rights reserved.
//

#import <Foundation/Foundation.h>

/**************************The node point for the graph********************************/
@interface EasyMetroGraphNodePoint : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *linkRoutes;

@end
/**************************The node which represents each stop********************************/
@interface EasyMetroGraphNode : NSObject

@property (nonatomic, strong) EasyMetroGraphNodePoint *point;

+ (EasyMetroGraphNode *) nodeWithPoint:(EasyMetroGraphNodePoint*)point;
+ (EasyMetroGraphNode *)nodeWithIdentifier:(NSString *)anIdentifier;

@end
/**************************The Edge which represents each path between two stops***************************/
@interface EasyMetroGraphEdge : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong)NSNumber *weight;
+ (EasyMetroGraphEdge *) edgeWithName:(NSString *)aName andWeight:(NSNumber *)aNumber;

@end
/*************************The route object for the two points in a path***************************/

@interface EasyMetroGraphPath : NSObject

@property (nonatomic, readonly) NSMutableArray *  pathWays;

@property (nonatomic, readonly) int               count;

- (void) addPathFromNode:(EasyMetroGraphNode *)fromNode withEdge:(EasyMetroGraphEdge *)edge;

@end

/*************************The object for edges comprising the route***************************/

@interface EasyMetroGraphPathWay : NSObject

@property (nonatomic, strong, readonly) EasyMetroGraphNode *node;
@property (nonatomic, strong, readonly) EasyMetroGraphEdge		*edge;
- (id) initWithNode:(EasyMetroGraphNode *)node andEdge:(EasyMetroGraphEdge *)edge;


@end

/*************************The graph object for converting the map to graph data***************************/

@interface EasyMetroGraph : NSObject

@property (nonatomic, readonly) NSDictionary *nodes;

- (EasyMetroGraphNode *)getNodeFromGraph:(NSString *)nodeId;

- (void) addEdgeBetweenNodes:(EasyMetroGraphEdge *)anEdge fromNode:(EasyMetroGraphNode *)nodeA toNode:(EasyMetroGraphNode *)nodeB;

- (EasyMetroGraphPath *)getRouteFromStop:(EasyMetroGraphNode *)fromStop toStop:(EasyMetroGraphNode *)toStop;
@end


