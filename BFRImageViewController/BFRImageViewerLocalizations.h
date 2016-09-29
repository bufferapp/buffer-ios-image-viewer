//
//  BFRImageViewerLocalizations.h
//  BFRImageViewer
//
//  Created by Jordan Morgan on 9/29/16.
//  Copyright © 2016 Andrew Yates. All rights reserved.
//

#ifndef BFRImageViewerLocalizations_h
#define BFRImageViewerLocalizations_h

#ifndef BFRImageViewerLocalizedStrings
#define BFRImageViewerLocalizedStrings(key, comment) \
NSLocalizedStringFromTableInBundle(key, nil, [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"BFRImageViewerLocalizations" ofType:@"bundle"]], comment)
#endif

#endif /* BFRImageViewerLocalizations_h */
