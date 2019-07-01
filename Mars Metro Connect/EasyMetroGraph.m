//
//  EasyMetroGraph.m
//  Mars Metro Connect
//
//  Created by Murali Krishnan Govindarajulu on 10/26/15.
//  Copyright © 2015 EasyMetro. All rights reserved.
//

#import "EasyMetroGraph.h"
#define STR_EMPTY @""

@implementation EasyMetroGraphNodePoint


- (id)init
{
    self = [super init];
    if (self) {
        _identifier = STR_EMPTY;
        _title			= STR_EMPTY;
        _linkRoutes = nil;
    }
    return self;
}

@end

@implementation EasyMetroGraphNode

- (id)init
{
    self = [super init];
    if (self) {
        _point = [[EasyMetroGraphNodePoint alloc] init];
    }
    return self;
}

+ (EasyMetroGraphNode *)nodeWithPoint:(EasyMetroGraphNodePoint*)point
{
    EasyMetroGraphNode *node = [[EasyMetroGraphNode alloc] init];
    node.point = point;
    return node;
}

+ (EasyMetroGraphNode *)nodeWithIdentifier:(NSString *)anIdentifier
{
    EasyMetroGraphNode *node	= [[EasyMetroGraphNode alloc] init];
    node.point.identifier = anIdentifier;
    
    return node;
}
@end

@implementation EasyMetroGraphEdge

- (id) init
{
    self = [super init];
    if (self)
    {
        _weight = [NSNumber numberWithInt:1];
        _name		= STR_EMPTY;
    }
    return self;
}

+ (EasyMetroGraphEdge *)edgeWithName:(NSString *)aName andWeight:(NSNumber *)aNumber
{
    EasyMetroGraphEdge *anEdge = [[EasyMetroGraphEdge alloc] init];
    anEdge.weight = aNumber;
    anEdge.name		= aName;
    return anEdge;
}
@end

@implementation EasyMetroGraphPath

- (id)init
{
    if ( self = [super init] )
    {
        _pathWays = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addPathFromNode:(EasyMetroGraphNode *)fromNode withEdge:(EasyMetroGraphEdge *)edge
{
    EasyMetroGraphPathWay *pathWay = [[EasyMetroGraphPathWay alloc] initWithNode:fromNode andEdge:edge];
    [_pathWays addObject:pathWay];
}

- (int)count
{
    return (int)_pathWays.count;
}

@end


@implementation EasyMetroGraphPathWay


- (id) initWithNode:(EasyMetroGraphNode *)node andEdge:(EasyMetroGraphEdge *)edge;
{
    self = [super init];
    if (self)
    {
        _node  = node;
        _edge		 = edge;
    }
    return self;
}

@end


@implementation EasyMetroGraph
{
    NSMutableDictionary *_nodeEdges;
    NSMutableDictionary *_nodes;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _nodeEdges	= [[NSMutableDictionary alloc] init];
        _nodes			= [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (EasyMetroGraphNode *)getNodeFromGraph:(NSString *)nodeId
{
    return [_nodes objectForKey:nodeId];
}

- (void) addEdgeBetweenNodes:(EasyMetroGraphEdge *)anEdge fromNode:(EasyMetroGraphNode *)nodeA toNode:(EasyMetroGraphNode *)nodeB
{
    [_nodes setObject:nodeA forKey:nodeA.point.identifier];
    [_nodes setObject:nodeB forKey:nodeB.point.identifier];
    
    if ( [_nodeEdges objectForKey:nodeA.point.identifier] == nil )
    {
        NSMutableDictionary *dic = [NSMutableDictionary
                                    dictionaryWithObject:anEdge
                                    forKey:nodeB.point.identifier];
        
        [_nodeEdges setObject:dic forKey:nodeA.point.identifier];
    }
    else
    {
        [(NSMutableDictionary *)
         [_nodeEdges objectForKey:nodeA.point.identifier]
         setObject:anEdge forKey:nodeB.point.identifier];
    }
}


- (EasyMetroGraphPath *)getRouteFromStop:(EasyMetroGraphNode *)fromStop toStop:(EasyMetroGraphNode *)toStop
{
    NSMutableDictionary *nodesToBeTraversed = [NSMutableDictionary dictionaryWithDictionary:_nodes];
    
    NSMutableDictionary *distanceFromBoardingPoint = [NSMutableDictionary dictionaryWithCapacity:nodesToBeTraversed.count];
    
    NSMutableDictionary *previousNodeInOptimalPath = [NSMutableDictionary dictionaryWithCapacity:nodesToBeTraversed.count];
    
    NSNumber *infinity = [ NSNumber numberWithInt: -1 ];
    for (NSString *nodeIdentifier in nodesToBeTraversed)
    {
        [distanceFromBoardingPoint setValue:infinity forKey:nodeIdentifier];
    }
    
    [distanceFromBoardingPoint setValue:[NSNumber numberWithInt:0] forKey:fromStop.point.identifier];
    
    NSString *currentlyExaminedIdentifier = nil;
    
    while ( [nodesToBeTraversed count] > 0 )
    {
        
        NSString *identifierOfSmallestDist = [self getKeyForMinimumValue:distanceFromBoardingPoint withInKeys:[nodesToBeTraversed allKeys]];
        
        if ( !identifierOfSmallestDist ) break;
        else
        {
            EasyMetroGraphNode *nodeLastVisited = [self getNodeFromGraph:identifierOfSmallestDist];
            
            if ( [identifierOfSmallestDist isEqualToString:toStop.point.identifier] )
            {
                currentlyExaminedIdentifier = toStop.point.identifier;
                break;
            }
            else
            {
                [nodesToBeTraversed removeObjectForKey:identifierOfSmallestDist];
                
                NSMutableSet *adjacentNodes = [NSMutableSet set];
                EasyMetroGraphNode *identifiedNode = [_nodes objectForKey:identifierOfSmallestDist];
                if (identifiedNode == nil) {
                    adjacentNodes = nil;
                }
                else
                {
                    NSDictionary *edgesFromNode = [_nodeEdges objectForKey:identifiedNode.point.identifier];
                    
                    if (edgesFromNode)
                    {
                        for (NSString *neighboringNodeIdentifier in edgesFromNode)
                        {
                            [adjacentNodes addObject:[_nodes objectForKey:neighboringNodeIdentifier]];
                        }
                    }
                }
                
                for (EasyMetroGraphNode *adjacentNode in adjacentNodes)
                {
                    NSNumber *graphEdgeWeight;
                    if ( ! [_nodeEdges objectForKey:nodeLastVisited.point.identifier])
                    {
                        graphEdgeWeight = nil;
                    }
                    else
                    {
                        graphEdgeWeight = [[[_nodeEdges objectForKey:nodeLastVisited.point.identifier]
                                            objectForKey:adjacentNode.point.identifier] weight];
                    }
                    
                    NSNumber *alt = [NSNumber numberWithFloat:
                                     [[distanceFromBoardingPoint objectForKey:identifierOfSmallestDist] floatValue] +
                                     [graphEdgeWeight floatValue]];
                    
                    NSNumber *distanceFromNeighborToOrigin = [distanceFromBoardingPoint objectForKey:adjacentNode.point.identifier];
                    
                    if ([distanceFromNeighborToOrigin isEqualToNumber:infinity] || [alt compare:distanceFromNeighborToOrigin] == NSOrderedAscending)
                    {
                        [distanceFromBoardingPoint setValue:alt forKey:adjacentNode.point.identifier];
                        [previousNodeInOptimalPath setValue:nodeLastVisited forKey:adjacentNode.point.identifier];
                    }
                }
            }
        }
    }
    
    if ( currentlyExaminedIdentifier == nil || ! [currentlyExaminedIdentifier isEqualToString:toStop.point.identifier]) return nil;
    else
    {
        EasyMetroGraphPath *pathForTravel = [[EasyMetroGraphPath alloc] init];
        
        NSMutableArray *nodesInReverseOrder = [NSMutableArray array];
        [nodesInReverseOrder addObject:toStop];
        
        EasyMetroGraphNode *lastStepNode = toStop;
        EasyMetroGraphNode *previousNode;
        
        while ((previousNode = [previousNodeInOptimalPath objectForKey:lastStepNode.point.identifier]))
        {
            [nodesInReverseOrder addObject:previousNode];
            lastStepNode = previousNode;
        }
        
        NSUInteger nodesCountForPath = [nodesInReverseOrder count];
        
        for (int i = (int)(nodesCountForPath - 1); i >= 0; i--)
        {
            EasyMetroGraphNode *currentGraphNode = [nodesInReverseOrder objectAtIndex:i];
            EasyMetroGraphNode *nextGraphNode = (i - 1 < 0) ? nil : [nodesInReverseOrder objectAtIndex:(i - 1)];
            EasyMetroGraphEdge *newGraphEdge;
            if (nextGraphNode && [_nodeEdges objectForKey:currentGraphNode.point.identifier]) {
                newGraphEdge =  [[_nodeEdges objectForKey:currentGraphNode.point.identifier]
                                 objectForKey:nextGraphNode.point.identifier];
            }
            else
            {
                newGraphEdge = nil;
            }
            
            [pathForTravel addPathFromNode:currentGraphNode withEdge:newGraphEdge];
        }
        
        return pathForTravel;
    }
}

- (id) getKeyForMinimumValue:(NSDictionary *)dict withInKeys:(NSArray *)anArray
{
    id minKeyValue	= nil;
    NSNumber *smallestValue = nil;
    NSNumber *infinity			= [NSNumber numberWithInt:-1];
    
    for (id key in anArray)
    {
        NSNumber *currentKey = [dict objectForKey:key];
        
        if ( ! [currentKey isEqualToNumber:infinity])
        {
            if (smallestValue == nil || [smallestValue compare:currentKey] == NSOrderedDescending)
            {
                minKeyValue = key;
                smallestValue = currentKey;
            }
        }
    }
    
    return minKeyValue;
}



@end
