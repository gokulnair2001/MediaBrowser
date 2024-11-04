//
//  CVPlayerViewController.swift
//  Powerplay
//
//  Created by Deepak Goyal on 07/08/23.
//

import UIKit


protocol CVPlayerViewControllerDelegate: AnyObject{
    
    /**
  
     If URL is appropriate and video is Ready to playing / start playing
     
     */
    func didReadyToPlay()
    
    /**
     
     Something is wrong and video is failed to play
     
     */
    func didFailToPlay()
    
    /**
     
     Delegate which notifies for video play status
     
     */
    func didTapPlay()
    
    /**
     
     Delegate which notifies for video pause status
     
     */
    func didTapPause()
}
