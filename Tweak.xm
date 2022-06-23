#import <UIKit/UIKit.h>

@interface YTPlayerViewController : UIViewController
-(float)currentPlaybackRateForVarispeedSwitchController:(id)arg1;
@end

@interface UIView ()
@property(nonatomic, readwrite) UIView *overlayView;
@property(nonatomic, readwrite) UIView *playerBar;
@property(nonatomic, readwrite) UILabel *durationLabel;
@end

static NSString* secsToTime(int secs) {
	NSUInteger h = secs / 3600;
	NSUInteger m = (secs / 60) % 60;
	NSUInteger s = secs % 60;
	if (h == 0) {
		return [NSString stringWithFormat:@"%lu:%02lu", m, s];
	} else {
		return [NSString stringWithFormat:@"%lu:%02lu:%02lu", h, m, s];
	}
}

static void modifyLabel(UILabel *label, int totalTime, int elapsedTime, float videoSpeed) {
	NSString *trueTimestamp = [NSString stringWithFormat:@"%@/%@", secsToTime((int) (elapsedTime / videoSpeed)), secsToTime((int) (totalTime / videoSpeed))];
	if (videoSpeed != 1.0 && ![label.text containsString:@" - "]) [label setText:[NSString stringWithFormat:@"%@ - %@", label.text, trueTimestamp]];
	[label sizeToFit];
}

%hook YTPlayerViewController
-(void)singleVideo:(id)arg1 currentVideoTimeDidChange:(id)arg2 {
	%orig;

	// Fixes crash with auto-playing videos on the home page
	if ([self.view.overlayView class] != %c(YTMainAppVideoPlayerOverlayView)) return;

	float totalTime = [[self.view.overlayView.playerBar valueForKey:@"_totalTime"] intValue];
	float elapsedTime = [[self.view.overlayView.playerBar valueForKey:@"_roundedMediaTime"] intValue];

	UILabel *progressLabel = self.view.overlayView.playerBar.durationLabel;
	modifyLabel(progressLabel, totalTime, elapsedTime, [self currentPlaybackRateForVarispeedSwitchController:nil]);
}
%end
