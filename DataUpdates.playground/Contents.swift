//: A UIKit based Playground for presenting user interface
  
import UIKit
import Combine
import PlaygroundSupport


class Model {
    var value = CurrentValueSubject<Int, Never>(0)
}


let model = Model()

class MyViewController : UIViewController {

    var label: UILabel!
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Hello World!"
        label.textColor = .black
        
        view.addSubview(label)
        self.view = view
        self.label = label
    }
    var bag = Set<AnyCancellable>()
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.publish(every: 1.0,
                      on: RunLoop.current,
                      in:.common).autoconnect().map { (date:Date) -> Int in
                        let value = model.value.value
                        return value + 1
                      }.sink { (value:Int) in
                        model.value.send(value)
                      }.store(in: &self.bag)
        model.value.map { (value:Int) -> String in
            return "\(value)"
        }.sink { [weak self](value:String) in
            self?.label.text = value
        }.store(in: &self.bag)
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
