Tesseract OCR iOS Example Project
=================

**Tesseract OCR iOS is a Framework for iOS5+ (includes iOS 7).**


<br/>
Template Framework Project
=================
You can use the "**Template Framework Project**". It's a starting point for use the Tesseract Framework. It's iOS7 and arm64 ready!

Into the tessdata folder (linked like a referenced folder into the project), there are the .traineddata language files.

Now you can use Tesseract class like explained into the "How to use" section:

<br/>
How to use
=================

**MyViewController.h**
<pre><code>#import &lt;TesseractOCR/TesseractOCR.h&gt;</code>
<code>@interface MyViewController : UIViewController &lt;TesseractDelegate&gt;</code>
<code>@end</code></pre>
  
<br />
**MyViewController.m**
<pre><code>
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // language are used for recognition. Ex: eng. Tesseract will search for a eng.traineddata file in the dataPath directory; eng+ita will search for a eng.traineddata and ita.traineddata.
    
    //Like in the Template Framework Project:
	// Assumed that .traineddata files are in your "tessdata" folder and the folder is in the root of the project.
	// Assumed, that you added a folder references "tessdata" into your xCode project tree, with the ‘Create folder references for any added folders’ options set up in the «Add files to project» dialog.
	// Assumed that any .traineddata files is in the tessdata folder, like in the Template Framework Project

    //Create your tesseract using the initWithLanguage method:
	// Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:@"<strong>eng+ita</strong>"];
    
    // set up the delegate to recieve tesseract's callback
    // self should respond to TesseractDelegate and implement shouldCancelImageRecognitionForTesseract: method
    // to have an ability to recieve callback and interrupt Tesseract before it finishes
    
    Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:@"eng+ita"];
    tesseract.delegate = self;
    
    [tesseract setVariableValue:@"0123456789" forKey:@"tessedit_char_whitelist"]; //limit search
    [tesseract setImage:[UIImage imageNamed:@"image_sample.jpg"]]; //image to check
    [tesseract recognize];
    
    NSLog(@"%@", [tesseract recognizedText]);

    tesseract = nil; //deallocate and free all memory
}


- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract
{
    NSLog(@"progress: %d", tesseract.progress);
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}
</code></pre>


Set Tesseract variable key to value. See http://www.sk-spell.sk.cx/tesseract-ocr-en-variables for a complete (but not up-to-date) list.

For instance, use tessedit_char_whitelist to restrict characters to a specific set.

<br/>

<br/>
Dependencies
=================

Tesseract OCR iOS use UIKit, Foundation and CoreFoundation. They are already included in standard iOS Projects.

License
=================

Tesseract OCR iOS and TesseractOCR.framework are under MIT License.

Tesseract, powered by Google http://code.google.com/p/tesseract-ocr/, is under Apache License.


Author Infos
=================

* Original project and readme: Daniele Galiotto - iOS Freelance Developer - **www.g8production.com**
* This project: Michael Roher - iOS Freelance Developer - **www.mikeroher.com**
