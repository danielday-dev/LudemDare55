extends Node2D

func setProgress(percentage : float):
	var frameMax : int = $AnimatedSprite.sprite_frames.get_frame_count("Progress") - 1;
	$AnimatedSprite.frame = clamp(round(percentage * (frameMax as float)), 0, frameMax); 
