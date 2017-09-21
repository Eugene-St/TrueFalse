//
//  ViewController.swift
//  TrueFalseStarter
//
//  Created by Pasan Premaratne on 3/9/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import UIKit
import GameKit
import AudioToolbox

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var optionOne: UIButton!
    @IBOutlet weak var optionTwo: UIButton!
    @IBOutlet weak var optionFour: UIButton!
    @IBOutlet weak var optionThree: UIButton!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var currentPosition: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var playAgain: UIButton!
    
    var soundProvider = SoundProvider()
    var questionProvider = QuestionsProvider()
    var colorsProvider = ColorsProvider()
    var timer: Timer = Timer()
    var seconds = 15
    var game = QuestionsProvider()
    var answerButtons: [UIButton] = []
    
    //Start the app
    override func viewDidLoad() {
        super.viewDidLoad()

    answerButtons = [optionOne, optionTwo, optionThree, optionFour]
    
    soundProvider.loadGameStartSound()
    
    soundProvider.playGameStartSound()
        
    displayQuestion()
    
    //Stylize buttons borders
    for button in answerButtons
    {
        button.layer.cornerRadius = 10.0
    }

    }
    
    //--------------------------
    
    func displayQuestion()
    {
        game.pickQuestion()
        questionField.text = game.questionToDisplay.question
        
        for button in answerButtons
        {
            button.backgroundColor = colorsProvider.activeButtonColor
            button.setTitleColor(UIColor.lightGray, for: UIControlState.disabled)
            button.isEnabled = true
        
        }
        
        assignButtonTitles()
        
        playAgain.isHidden = true
        answerLabel.isHidden = true
        currentPosition.isHidden = false
        currentPosition.text = "\(game.questionsAsked)/\(game.questionsPerRound)"
        startTimer()
        
        seconds = 15
        timerLabel.text = "\(seconds)"
        timerLabel.isHidden = true
        
    }
    
    func startTimer()
    {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func updateTimer()
    {
        seconds -= 1
        timerLabel.text = "\(seconds)"
        if seconds == 0
        {
            let button = UIButton(type: .system)
            button.setTitle("Time Expired", for: .normal)
            checkAnswer(button)
            timer.invalidate()
        }
        else if seconds <= 8
        {
            let modulo: Bool = seconds % 2 == 0
            switch modulo {
            case false:
                for button in answerButtons
                {
                    button.backgroundColor = colorsProvider.activeButtonColor
                }
            default:
                for button in answerButtons
                {
                    button.backgroundColor = UIColor.white
                }
            }
        }
    }
    
    //---------------------------
    
    func assignButtonTitles()
    {
        let newQuestion = game.questionToDisplay
        let numberOfChoices: Int = newQuestion.possibleChoices.count
        game.randomizedAnswerChoices()
        
        for buttonIndex in 0..<numberOfChoices
        {
            var consumedIndexes = game.consumedIndexes
            let randomIndex = consumedIndexes[0]
            answerButtons[buttonIndex].setTitle(newQuestion.possibleChoices[randomIndex], for: .normal)
            game.consumedIndexes.remove(at: 0)
        }
        
        if numberOfChoices < answerButtons.count
        {
            disableButtons(usingIndexes: numberOfChoices)
        }
    }
    
    //------------------------------
        
    func disableButtons(usingIndexes numberOfChoices: Int)
        {
            if numberOfChoices < answerButtons.count
            {
                for index in numberOfChoices..<answerButtons.count
                {
                    let button = answerButtons[index]
                    button.setTitle("N/A", for: .normal)
                    button.isEnabled = false
                    button.backgroundColor = colorsProvider.gray
                }
            }
        }
    
    //-------------
    
    func displayResult() -> String {
        
        let a = "Спасибо за Ваше время!\nВы ответили правильно на \(game.correctQuestions)"
        let b = "из \(game.questionsPerRound)!"
        
        switch game.questionsPerRound {
        case 2,3,4: return a + " вопроса " + b
        case 1: return a + " вопрос " + b
        default: return a + " вопросов " + b
        }
    }
    
    func displayScore()
    {
        questionField.text = displayResult()
        
        game = QuestionsProvider()
        
        for button in answerButtons
        {
            button.isHidden = true
        }
        
        playAgain.isHidden = false
    }
 

    @IBAction func checkAnswer(_ sender: UIButton) {
        if timer.isValid
        {
            timer.invalidate()
        }
        timerLabel.isHidden = true
        
        let correctAnswer = game.correctAnswer
        
        for button in answerButtons
        {
            button.isEnabled = false
            button.backgroundColor = colorsProvider.activeButtonColor
        }
        
        if sender.currentTitle == correctAnswer
        {
            game.correctQuestions += 1
            answerLabel.textColor = colorsProvider.correctColorAlpha
            answerLabel.text = "Ага"
            sender.backgroundColor = colorsProvider.correctColor
            sender.setTitleColor(UIColor.white, for: UIControlState.disabled)
        }
        else
        {
            
            answerLabel.textColor = colorsProvider.incorrectColorAlpha
            answerLabel.text = "Неа..."
            sender.backgroundColor = colorsProvider.incorrectColor
            
            for button in answerButtons {
                if button.currentTitle == correctAnswer
                {
                    button.backgroundColor = colorsProvider.correctColor
                    let brightWhite = UIColor(white: 1.0, alpha: 1.0)
                    button.setTitleColor(brightWhite, for: UIControlState.disabled)
                }
            }
        }
        
        answerLabel.isHidden = false
        game.questionsAsked += 1
        loadNextRoundWithDelay(seconds: 2)
        currentPosition.isHidden = true
    }
    
    func nextRound()
    {
        if game.questionsAsked == game.questionsPerRound
        {
            displayScore()
        }
        else
        {
            if game.questionsAsked != 0
            {
                game.questions.remove(at: game.selectedIndex)
            }
            displayQuestion()
        }
    }
    
    @IBAction func playAgainButton()
    {
        for button in answerButtons
        {
            button.isHidden = false
        }
        nextRound()
    }

    
    func loadNextRoundWithDelay(seconds: Int)
    {
        let delay = Int64(NSEC_PER_SEC * UInt64(seconds))
        
        let dispatchTime = DispatchTime.now() + Double(delay) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.answerLabel.isHidden = true
            self.nextRound()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}





































