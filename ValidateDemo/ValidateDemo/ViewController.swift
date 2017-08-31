
import UIKit
import RxCocoa
import RxSwift
import RxOptional

class ViewController: UIViewController {

    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidOutlet: UILabel!
    
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidOutlet: UILabel!
    
    @IBOutlet weak var doSomethingOutlet: UIButton!
    
    @IBOutlet weak var repeatPasswordOutlet: UITextField!
    @IBOutlet weak var repeatPasswordValidOutlet: UILabel!
    
    let minimalPasswordLength = 5
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordValidOutlet.text = "Password should contain \(minimalPasswordLength) characters"
        usernameValidOutlet.text = "Invalid email address"
        usernameValidOutlet.isHidden = true
        passwordValidOutlet.isHidden = true
        repeatPasswordValidOutlet.text = "Repeat password does not match to password"
        repeatPasswordValidOutlet.isHidden = true
        
        let usernameValid = usernameOutlet.rx.text.filterNil().validate(StringRule.email).isValid().shareReplay(1)
        
        let passwordValid = passwordOutlet.rx.text.orEmpty
            .map { $0.characters.count >= self.minimalPasswordLength }
            .shareReplay(1)
        
        let repeatPasswordValid = Observable.combineLatest(passwordOutlet.rx.text, repeatPasswordOutlet.rx.text) { (password,repeatPass) -> Bool in
            guard let password = password, let repeatPassword = repeatPass else { return false }
            if password.isEmpty && repeatPassword.isEmpty { return false }
            return password == repeatPass
            }.shareReplay(1)
        
        let everythingValid =
            Observable.combineLatest(usernameValid, passwordValid,repeatPasswordValid) { $0 && $1 && $2}
                .shareReplay(1)
        
        everythingValid.sample(doSomethingOutlet.rx.tap).bind(onNext: { self.showAlert(for: $0)}).addDisposableTo(disposeBag)
        usernameValid.sample(doSomethingOutlet.rx.tap).bind(to: usernameValidOutlet.rx.isHidden).addDisposableTo(disposeBag)
        passwordValid.sample(doSomethingOutlet.rx.tap).bind(to: passwordValidOutlet.rx.isHidden).addDisposableTo(disposeBag)
        repeatPasswordValid.sample(doSomethingOutlet.rx.tap).bind(to: repeatPasswordValidOutlet.rx.isHidden).addDisposableTo(disposeBag)
        
    }
    
    func showAlert(for isSuccess: Bool) {
        var alert = UIAlertController()
        if isSuccess {
            alert = UIAlertController(title: "Success", message: "Logged with success", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        } else {
            print("Error")
            return
        }
        
        present(alert, animated: true)
    }


}

