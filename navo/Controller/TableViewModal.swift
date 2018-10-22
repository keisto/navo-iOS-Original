import UIKit
import D2PCurvedModal

extension ViewController : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if presented is D2PCurvedModal {
            if let statusbar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                statusbar.backgroundColor = UIColor.init(red: 48.0/255, green: 78.0/255, blue: 88.0/255, alpha: 1.0)
            }
            transition.opening = true
            return transition
        }
        
        return nil
        
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if dismissed is D2PCurvedModal {
            if let statusbar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                statusbar.backgroundColor = UIColor.init(red: 0.0/255, green: 158.0/255, blue: 222.0/255, alpha: 1.0)
            }
            transition.opening = false
            return transition
        }
        
        return nil
        
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        return percentDrivenTransition.transitionInProgress ? percentDrivenTransition : nil

    }
}
