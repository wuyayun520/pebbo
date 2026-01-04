
//: Declare String Begin

/*: "LaunchImage" :*/
fileprivate let notiRevenueCount:String = "will global agent foundation filterLa"
fileprivate let show_acrossState:[Character] = ["u","n","c","h","I","m","a","g","e"]

//: Declare String End

// __DEBUG__
// __CLOSE_PRINT__
//
//  LanguageViewController.swift
//  OverseaH5
//
//  Created by DouXiu on 2025/11/27.
//

//: import UIKit
import UIKit

//: class WaitViewController: UIViewController {
class LanguageViewController: UIViewController {
    //: override func viewDidLoad() {
    override func viewDidLoad() {
        //: super.viewDidLoad()
        super.viewDidLoad()
        //: let bgImgV = UIImageView()
        let bgImgV = UIImageView()
        //: bgImgV.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        bgImgV.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        //: bgImgV.image = UIImage(named: "LaunchImage")
        bgImgV.image = UIImage(named: (String(notiRevenueCount.suffix(2)) + String(show_acrossState)))
        //: view.addSubview(bgImgV)
        view.addSubview(bgImgV)
    }
}
