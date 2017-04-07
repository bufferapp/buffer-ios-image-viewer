# BFRImageViewer

<p align="center">
  <img src="/demo.gif?raw=true" alt="Demo" />
</p>
<p align="center">
  <img src="https://img.shields.io/cocoapods/p/BFRImageViewer.svg" />
  <img src="https://img.shields.io/cocoapods/v/BFRImageViewer.svg" />
  <img src="https://img.shields.io/cocoapods/l/BFRImageViewer.svg" />
</p>

### Summary
The BFRImageViewer is a turnkey solution to present images within your iOS app 🎉! 

If features swipe gestures to dismiss, automatic image scaling, zooming and panning, supports multiple images, image types, URL backloading, custom view controller transitions and plays nicely with 3D touch! We use it all over the place in [Buffer for iOS](https://itunes.apple.com/us/app/buffer-for-twitter-pinterest/id490474324?mt=8) :-). 

We've got code samples of each feature in the demo app, feel free to take a peek 👀.

### Installation
The BFRImageViewer is hosted on CocoaPods and is the recommended way to install it:
```ruby
pod 'BFRImageViewer'
```


### Quickstart
To get up and running quickly with BFRImageViewer, just initialize it - that's really about it!
```objc
//Image source can be an array containing a mix of PHAssets, NSURLs, URL strings, UIImage or BFRBackLoadedImageSource
BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:@[image]];
```
```swift
let imageVC = BFRImageViewController(imageSource: [image])
```
From there, you'll have every photo automagically loaded up and be able to page between them. If you want some additional context, just fire up the demo project and take a peek 👌!

### Custom Transition
If you'd like to use a custom view controller transition, which zooms the selected image into the image viewer, just set up some properties on the dedicated image viewer animator class:
```objc
// In viewDidLoad...
self.imageViewAnimator = [BFRImageTransitionAnimator new];

// Later on, when you want to show an image...
self.imageViewAnimator.animatedImageContainer = self.imageView;
self.imageViewAnimator.animatedImage = self.imageView.image;
self.imageViewAnimator.imageOriginFrame = self.imageView.frame;
self.imageViewAnimator.desiredContentMode = self.imageView.contentMode; //Optional

BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:@[self.imageView.image]];
imageVC.transitioningDelegate = self.imageViewAnimator; 

[self presentViewController:imageVC animated:YES completion:nil];
```
That will give you this effect (excuse the low quality gif 🙈):
<p align="center">
  <img src="/transition.gif?raw=true" alt="AnimationDemo" />
</p>

### URL Backloading
Say you've got a thumbnail of an image, but also a URL of the higher fidelity version too. Using URL backloading, you can quickly show the lower resolution image while loading the better version in the background. When it loads - we'll automatically swap it out for you. This allows you to have the best of worlds. You don't need to have users wait for the URL to load, or settle for always viewing the degraded image.
```objc
- (void)openImageViewer {
    BFRBackLoadedImageSource *backloadedImage = [[BFRBackLoadedImageSource alloc] initWithInitialImage:[UIImage imageNamed:@"lowResImage"] hiResURL:[NSURL URLWithString:@"cdn.theURl.png"]];
    BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:@[backloadedImage]];
    [self presentViewController:imageVC animated:YES completion:nil];
}
```

### Going Forward
We regularly maintain this code, and you can also rest assured that it's been battle tested against thousands of users in production 👍. That said, we get things wrong from time to time - so feel free to open an issue for anything you spot!

We are always happy to talk shop, so feel free to give us a shout on Twitter:

+ Andy - [@ay8s](http://www.twitter.com/ay8s)
+ Jordan - [@jordanmorgan10](http://www.twitter.com/jordanmorgan10)

Or, hey - why not work on the BFRImageViewer and get paid for it!? [We're hiring](http://www.buffer.com/journey)!

- - -
#### Licence
_This project uses MIT License._
