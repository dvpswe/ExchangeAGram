//
//  FilterViewController.swift
//  ExhangeAGram
//
//  Created by Darryl Pendergrass on Oct/12/15.
//  Copyright © 2015 Phoenix Media Services, LLC. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var thisFeedItem: FeedItem!
    
    var collectionView: UICollectionView!
    
    let kIntensity = 0.7
    
    var context:CIContext = CIContext(options: nil)
    
    var filters:[CIFilter] = []
    
    var placeHolderImage = UIImage(named: "Placeholder")
    
    let tmpCache = NSTemporaryDirectory()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "MyFilterCell")
        self.view.addSubview(collectionView)
        
        filters = photoFilters()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell:FilterCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyFilterCell", forIndexPath: indexPath) as! FilterCell
        
        cell.imageView.image = placeHolderImage
        
        let filterQueue:dispatch_queue_t = dispatch_queue_create("filter queue", nil)
        
        dispatch_async(filterQueue, { () -> Void in
            let filterImage = self.getCachedImage(indexPath.row)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.imageView.image = filterImage
            })
            
        })

        return cell
    }
    
    //UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        createUIAlertController(indexPath)
        
        
        

    }
    
    //UIAlertController Helper Functions
    
    func createUIAlertController (indexPath: NSIndexPath) {
        let alert = UIAlertController(title: "Photo Options", message: "Please choose an option", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Add Caption!"
            textField.secureTextEntry = false
        }
        
        var text:String = ""
        let textField = alert.textFields![0] 
        if textField.text != nil {
            text = textField.text!
        }
        
        let photoAction = UIAlertAction(title: "Post Photo to Facebook with Caption", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
            self.shareToFacebook(indexPath)
            self.saveFilterToCoreData(indexPath, caption: text)
        }
        alert.addAction(photoAction)
        
        let saveFilterAction = UIAlertAction(title: "Save Filter without posting on Facebook", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            self.saveFilterToCoreData(indexPath, caption: text)
        }
        alert.addAction(saveFilterAction)
        
        let cancelAction = UIAlertAction(title: "Select another Filter", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in
        }
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //Helpers
    
    func photoFilters() -> [CIFilter] {
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls?.setValue(0.5, forKey: kCIInputSaturationKey)
       
        let sepia = CIFilter(name: "CISepiaTone")
        sepia?.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        //let colorClamp = CIFilter(name: "CIColorClamp")
        //colorClamp?.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        //colorClamp?.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite?.setValue(sepia?.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette!.setValue(composite?.outputImage, forKey: kCIInputImageKey)
        vignette?.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette?.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        let filters:[CIFilter]
        
        filters = [blur!, instant!, noir!, transfer!, unsharpen!, monochrome!, colorControls!, sepia!, /*colorClamp!,*/ composite!, vignette!]

        return filters
    }
    
    func filteredImageFromImage(imageData: NSData, filter: CIFilter) -> UIImage {
        
        let unfilteredImage = CIImage(data: imageData)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        let filteredImaged: CIImage = filter.outputImage!
        
        let extent = filteredImaged.extent
        
        let cgImage:CGImageRef = context.createCGImage(filteredImaged, fromRect: extent)
        
        let finalImage = UIImage(CGImage: cgImage)
        
        return finalImage
        
    }
    
    func saveFilterToCoreData (indexPath: NSIndexPath, caption: String) {
        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image!, filter: self.filters[indexPath.row])
        let imageData = UIImageJPEGRepresentation(filterImage, 1.0)
        self.thisFeedItem.image = imageData
        let thumbnailData = UIImageJPEGRepresentation(filterImage, 0.1)
        self.thisFeedItem.thumbNail = thumbnailData
        self.thisFeedItem.caption = caption
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func shareToFacebook (indexPath: NSIndexPath){
        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image!, filter: self.filters[indexPath.row])
        
        let photos:NSArray = [filterImage]
        let params = FBPhotoParams()
        params.photos = photos as [AnyObject]
        
        FBDialogs.presentMessageDialogWithPhotoParams(params, clientState: nil) { (call, result, error) -> Void in
            if (result != nil) {
                print(result)
            } else {
                print(error)
            }
        }
    }
    
    // caching functions
    
    func cacheImage (imageNumber: Int){
        let fileName = "\(imageNumber)"
        let uniquePath = (tmpCache as NSString).stringByAppendingPathComponent(fileName)

        if !NSFileManager.defaultManager().fileExistsAtPath(fileName){
            let data = self.thisFeedItem.thumbNail
            let filter = self.filters[imageNumber]
            let image = filteredImageFromImage(data!, filter: filter)
            UIImageJPEGRepresentation(image, 1.0)!.writeToFile(uniquePath as String, atomically: true)
        }
    }
    
    func getCachedImage (imageNumber: Int) -> UIImage {
        let fileName = "\(imageNumber)"
        let uniquePath = (tmpCache as NSString).stringByAppendingPathComponent(fileName)
        var image:UIImage
        
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            image = UIImage(contentsOfFile: uniquePath)!
        } else {
            self.cacheImage(imageNumber)
            image = UIImage(contentsOfFile: uniquePath)!
        }
        return image
    }
}
