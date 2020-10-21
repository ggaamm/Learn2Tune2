# Learn2Tune
An iOS project to tagging images with deep learning and human

### The definition of Learn2Tune

Learn2Tune allows users to create and fine tune image datasets by combining an manual and automatic prediction.

### Detailed functionality of the app  
User surfs on the map and drops pins on the map, and the app download images from Flickr corresponding to the map location, the images are displayed in a collection view. 

A single tap to any image selects that image, and a long tap deletes the image and downloads a new one at the current location. The new collection button erases all images and downloads a new set of images.

When an image is selected, the app sends the url of the image to my web service implemented on the Microsoft Azure. The webservice is a rest service of a resnet based image classification architcture that has 1000 classes. After the service does a prediction on the received url, it sends the predictions to the app. The app receives the predictions as labels and displays it to the user. 

After receiving the predictions, the user can also enter its own predictions through a textfield. The app stores all the images and predictions as labels of the images using core data. The user can retry to retrieve predictions from the user using the retry button. 

The downloaded images can be displayed via a tableview with their available predictions. The tableview is located in another tab of the application. By clicking on a row, the user seques to the predictions page.  

The user can delete the images by swiping left at the tableview or by long pressing the images at the pin details page.   

### Required frameworks
Mapkit: For displaying the map, annotations and obtaining the selected locations
Foundation: For establishing communications to the webservices such as Flickr and Azure
Core Data: For persistance of the images and labels
UIKit: To be able to insert all the user interface elements

#### Current Version
Current version does not include the functionality of backing up local images to the cloud.

