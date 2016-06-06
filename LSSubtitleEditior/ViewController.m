//
//  ViewController.m
//  LSSubtitleEditior
//
//  Created by Abhinav Singh on 01/06/16.
//  Copyright © 2016 No Organisation. All rights reserved.
//

#import "ViewController.h"

//http://carbonhacking.blogspot.in/2012/11/how-to-create-movie-subtitles-with.html
//What is .srt file ?
//
//.srt file stands for SubRip Text files. It contains simple formatted text data which was first written in France. The data in the .srt file is written in the following format.
//
//Subtitle number
//Start time --> End time
//Subtitle texts
//Blank line
//
//The Start time and End time are written in hours:minutes:seconds,milliseconds format.

@interface ViewController () {
    
    NSDateFormatter *timeFormatter;
    
    __weak IBOutlet NSTextField *filePathTextField;
    __weak IBOutlet NSTextField *durationTextField;
}

@property(nonatomic, strong) NSURL *subTitleUrlToChange;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    [timeFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    [timeFormatter setDateFormat:@"HH:mm:ss','SSS"];
    
    [filePathTextField setStringValue:@""];
}

-(IBAction)addFileClicked:(id)sender {
    
    NSOpenPanel *pannel = [NSOpenPanel openPanel];
    [pannel setAllowedFileTypes:@[@"srt"]];
    [pannel setCanChooseDirectories:NO];
    [pannel setCanChooseFiles:YES];
    [pannel setAllowsMultipleSelection:NO];
    
    __weak typeof(self) weakSelf = self;
    [pannel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            
            if (pannel.URLs.count) {
                
                weakSelf.subTitleUrlToChange = [pannel.URLs firstObject];
                NSString *fileName = [weakSelf.subTitleUrlToChange lastPathComponent];
                [filePathTextField setStringValue:fileName];
            }
        }
    }];
}

-(IBAction)doneClicked:(NSButton*)button {
    
    if (durationTextField.stringValue.doubleValue != 0) {
        
        NSTimeInterval toChangeInterval = (durationTextField.stringValue.doubleValue/1000.0);
        
        NSString *fileName = [self.subTitleUrlToChange lastPathComponent];
        [filePathTextField setStringValue:fileName];
        
        NSStringEncoding encoding;
        NSError *error;
        NSString *completeString = [NSString stringWithContentsOfURL:self.subTitleUrlToChange usedEncoding:&encoding error:&error];
        NSArray *allComponents = [completeString componentsSeparatedByString:@"\r\n\r\n"];
        
        NSArray *subComponents  = nil;
        NSArray *timeComponents  = nil;
        
        for ( NSString *strs in allComponents ) {
            
            subComponents = [strs componentsSeparatedByString:@"\r\n"];
            if (subComponents.count > 2) {
                
                NSString *timeString = [subComponents objectAtIndex:1];
                timeComponents = [timeString componentsSeparatedByString:@" --> "];
                
                if (timeComponents.count == 2) {
                    
                    NSString *startTimeString = timeComponents[0];
                    NSString *endTimeString = timeComponents[1];
                    
                    NSDate *startDate = [timeFormatter dateFromString:startTimeString];
                    NSDate *endDate = [timeFormatter dateFromString:endTimeString];
                    
                    NSDate *changedStartDate = [startDate dateByAddingTimeInterval:toChangeInterval];
                    NSDate *changedEndDate = [endDate dateByAddingTimeInterval:toChangeInterval];
                    
                    NSString *changedStartDateString = [timeFormatter stringFromDate:changedStartDate];
                    NSString *changedEndDateString = [timeFormatter stringFromDate:changedEndDate];
                    
                    completeString = [completeString stringByReplacingOccurrencesOfString:startTimeString withString:changedStartDateString];
                    completeString = [completeString stringByReplacingOccurrencesOfString:endTimeString withString:changedEndDateString];
                }
            }
        }
        
        NSString *fileNameWithoutExt = [fileName stringByDeletingPathExtension];
        NSString *newName = [fileNameWithoutExt stringByAppendingString:[NSString stringWithFormat:@"__%d.srt", (int)toChangeInterval]];
        
        NSString *newPath = [self.subTitleUrlToChange.path stringByReplacingOccurrencesOfString:fileName withString:newName];
        
        NSError *writeError = nil;
        [completeString writeToFile:newPath atomically:NO encoding:encoding error:&writeError];
    }
}

@end
