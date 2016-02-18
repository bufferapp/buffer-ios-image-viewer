#BFRImageViewer#

![Demo](/demo.gif?raw=true "Demo")

###Summary###
The BFRImageViewer is a turnkey solution to present images within your iOS app 🎉! It's based off of the excellent [IDMPhotoBrowser](https://github.com/ideaismobile/IDMPhotoBrowser), but tweaked for our own needs.

If features swipe gestures to dismiss, image scaling, zooming and panning, supports multiple images, image types, and plays nicely with 3D touch! We use it all over the place in [Buffer for iOS](https://itunes.apple.com/us/app/buffer-for-twitter-pinterest/id490474324?mt=8) :-).

###Installation###
The BFRImageViewer is hosted on CocoaPods and is the recommended way to install it:

`pod 'BFRImageViewer'`


###Quickstart###
To get up and running quickly with BFRImageViewer, just initialize it - that's really about it!

     //Image source can be an array containing a mix of PHAssets, NSURLs, url strings, or UIImage
     BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:@[image]];

From there, you'll have every photo automagically loaded up and be able to page between them. If you want some additional context, just fire up the demo project and take a peek 👌!

###Going Forward###
We regularly maintain this code, and you can also rest assured that it's been battle tested against thousands of users in production 👍. That said, we get things wrong from time to time - so feel free to open an issue for anything you spot!

We are always happy to talk shop, so feel free to give us a shout on Twitter:

+ Andy - [@ay8s](http://www.twitter.com/ay8s)
+ Jordan - [@jordanmorgan10](http://www.twitter.com/jordanmorgan10)
+ Humber -[goku2](http://www.twitter.com/goku2)

Or, hey - why not work on the BFRImageViewer and get paid for it!? [We're hiring](http://www.buffer.com/journey)!

- - -
######Licence######
_This project uses MIT License._