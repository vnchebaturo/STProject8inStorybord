//
//  ViewController.swift
//  lessonTimSTPlaingCard3
//
//  Created by Nikita on 30.09.2021.
//

import UIKit

class ViewController: UIViewController {
    
    var deck = PlayingCardDeck()
    
    
    @IBOutlet private var playingCardView: [PlayingCardView]!
    
    //MARK: Динамическое перемещение карт
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    lazy var cardBehavior = CardBehavior(in: animator)
    
    override func viewDidLoad(){
        super.viewDidLoad()
        var cards = [PlayingCard]()
        
        for _ in 1...((playingCardView.count+1)/2) { //создание карт с парным индексом
            let card = deck.draw()!
            cards += [card, card]
        }
        for cardView in playingCardView {
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.arc4random)  //рандомным образом присваиваеться по индексам карты
            cardView.rank = card.rank.order         //размещаем rang and suit
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))  //распознания касания
            //MARK: dinamik
                cardBehavior.addItem(cardView) // Динамическое перемещение карт
                  

        }
    }
    
    
    
    private var faceUpCardViews: [PlayingCardView] {
        return playingCardView.filter { $0.isFaceUp && !$0.isHidden && $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0) && $0.alpha == 1 }
    }
    
    private var faceUpCardViewsMatch : Bool {
        return faceUpCardViews.count == 2 &&
        faceUpCardViews[0].rank == faceUpCardViews[1].rank &&
        faceUpCardViews[0].suit == faceUpCardViews[1].suit
    }
    var lastChosenCardView: PlayingCardView?
    
    @objc func flipCard (_ recognizer: UITapGestureRecognizer) {
        // распознователь на какой карточке мы дотронулись
        switch recognizer.state {
        case .ended:
            if let chosenCardView = recognizer.view as? PlayingCardView, faceUpCardViews.count < 2 {
                lastChosenCardView = chosenCardView
                cardBehavior.removeItem(chosenCardView)
                UIView.transition(                      //анимация параметры
                    with: chosenCardView,
                    duration: 0.5,      //скорость вращения
                    options: [.transitionFlipFromLeft], //анимация на переворот а не растворение и др.
                    animations: {                       //закрытие анимации
                        chosenCardView.isFaceUp = !chosenCardView.isFaceUp //переворот
                    },
                    completion: { finished in           //обработчик завершения
                        let cardsToAnimate = self.faceUpCardViews
                        if self.faceUpCardViewsMatch {
                            UIViewPropertyAnimator.runningPropertyAnimator(
                                withDuration: 0.6,
                                delay: 0,
                                options: [],
                                animations: {
                                    cardsToAnimate.forEach {          //снова просмотреть карты
                                        $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
                                    }
                                },
                                completion: { position in
                                    UIViewPropertyAnimator.runningPropertyAnimator(
                                        withDuration: 0.75,
                                        delay: 0,
                                        options: [],
                                        animations: {
                                            cardsToAnimate.forEach {
                                                $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                                $0.alpha = 0
                                            }
                                        },
                                        completion: { position in
                                            cardsToAnimate.forEach {
                                                $0.isHidden = true
                                                $0.alpha = 1
                                                $0.transform = .identity
                                            }
                                        })
                                }
                            )
                        } else if cardsToAnimate.count == 2 {
                            if chosenCardView == self.lastChosenCardView {
                                cardsToAnimate.forEach { playingCardView in
                                    UIView.transition(
                                        with: playingCardView,
                                        duration: 3.0,  //скорость вращения
                                        options: [.transitionFlipFromLeft],
                                        animations: {
                                            playingCardView.isFaceUp = false
                                        },
                                        completion: { finished in
                                            self.cardBehavior.addItem(playingCardView)
                                        }
                                    )
                                }
                            }
                        } else {
                            if !chosenCardView.isFaceUp {
                                self.cardBehavior.addItem(chosenCardView)
                            }
                        }
                    }
                )
            }
        default:
            break
        }
    }
    
    
}


extension CGFloat {
    var arc4random: CGFloat {
        if self > 0 {
            return CGFloat(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -CGFloat(arc4random_uniform(UInt32(-self)))
        } else {
            return 0
        }
    }
}

//
//extension Double {
//    var arc4random: Double {
//        if self > 0 {
//            return Double(arc4random_uniform(UInt32(self)))
//        } else if self < 0 {
//            return Double(arc4random_uniform(UInt32(-self)))
//        } else {
//            return 0
//        }
//    }
//}

//    @IBOutlet weak var playingCardView: PlayingCardView! {
//        didSet {
//            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
//            swipe.direction = [.left, .right]
//            playingCardView.addGestureRecognizer(swipe)
//            let pinch = UIPinchGestureRecognizer(target: playingCardView, action: #selector(PlayingCardView.adjustFaceCardScale(byHandlingGestureRecoreRecognizedBy:)))
//            playingCardView.addGestureRecognizer(pinch)
//        }
//    }
//


//    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
//        switch sender.state{
//        case .ended:
//            playingCardView.isFaseUp = !playingCardView.isFaseUp
//        default: break
//        }
//    }
//
//
//    @objc func nextCard() {
//        if let card = deck.draw() {
//            playingCardView.rank = card.rank.order
//            playingCardView.suit = card.suit.rawValue
//        }
//
//    }

