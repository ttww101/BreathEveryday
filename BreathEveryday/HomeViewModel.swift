//
//  HomeViewManager.swift
//  BreathEveryday
//
//  Created by Lucy on 2017/4/17.
//  Copyright © 2017年 Bomi. All rights reserved.
//

import Foundation
import UIKit


struct Category {
    
    var name: String = ""
    
    var image: UIImage = UIImage()
    
    var button: UIButton = UIButton()
    
    var isCreated: Bool = false
    
    var frame: CGRect = CGRect()
    
    var color: UIColor = .lightGray
}

let categoryStringArray: [String] = ["Love",
                               "Family",
                               "Friend",
                               "Pet",
                               "Work",
                               "School",
                               "Study",
                               "Schedule",
                               "Music",
                               "Restaurant",
                               "Movie",
                               "Photography",
                               "Exercise",
                               "Fitness",
                               "Travel",
                               "Game",
                               "Car",
                               "Expense",
                               "Credit Card",
                               "Shopping",
                               "Religion",
                               "Mind",
                               "App",
                               "Smile",
                               "Sun",
                               "Night",
                               "Alcohol",
                               "Rocket",
                               "x"]

let categoryImageArray: [UIImage] = [#imageLiteral(resourceName: "Like-48"),
                             #imageLiteral(resourceName: "Family"),
                             #imageLiteral(resourceName: "Meeting-50"),
                             #imageLiteral(resourceName: "Cat Footprint"),
                             #imageLiteral(resourceName: "Business-50"),
                             #imageLiteral(resourceName: "Students-50"),
                             #imageLiteral(resourceName: "Magazine-50"),
                             #imageLiteral(resourceName: "Date To-50"),
                             #imageLiteral(resourceName: "Music-64"),
                             #imageLiteral(resourceName: "Restaurant-50"),
                             #imageLiteral(resourceName: "Movie-50"),
                             #imageLiteral(resourceName: "Photography"),
                             #imageLiteral(resourceName: "Exercise-50"),
                             #imageLiteral(resourceName: "Weightlifting-50"),
                             #imageLiteral(resourceName: "Airport-50"),
                             #imageLiteral(resourceName: "Visual Game Boy-50"),
                             #imageLiteral(resourceName: "Car-50"),
                             #imageLiteral(resourceName: "US Dollar-50"),
                             #imageLiteral(resourceName: "POS Terminal-50"),
                             #imageLiteral(resourceName: "Shopping Cart-50"),
                             #imageLiteral(resourceName: "Pray Filled-50"),
                             #imageLiteral(resourceName: "Mental State-50"),
                             #imageLiteral(resourceName: "Apple App Store-100"),
                             #imageLiteral(resourceName: "Smile"),
                             #imageLiteral(resourceName: "SunQ"),
                             #imageLiteral(resourceName: "Bat-50"),
                             #imageLiteral(resourceName: "Alcoholic Beverage Licensing-50"),
                             #imageLiteral(resourceName: "Rocket"),
                             #imageLiteral(resourceName: "fuck")]

var numberOfQuote = 0
let quotes:[String] = ["Steve Jobs - \nIf today was the last day of my life would I want to do what I’m about to do today?",
                       "Kobe Bryant - \nI don't talk trash often, but when I do, I go for the jugular.",
                       "William James - \nBe not afraid of life. Believe that life is worth living, and your belief will help create the fact.",
                       "Erma Bombeck - \nWhen I stand before God at the end of my life, I would hope that I would not have a single bit of talent left and could say, I used everything you gave me.",
                       "Mark Twain - \nThe secret of getting ahead is getting started.",
                       "Benjamin Disraeli - \nNurture your mind with great thoughts. To believe in the heroic makes heroes.",
                       "Ray Kroc - \nLuck is a dividend of sweat. The more you sweat, the luckier you get.",
                       "Carol Burnett - \nOnly I can change my life. No one can do it for me.",
                       "George Sand - \nThere is only one happiness in this life, to love and be loved.",
                       "Charles R. Swindoll - \nLife is 10% what happens to you and 90% how you react to it.",
                       "English Proverb - \nYou may find the worst enemy or best friend in yourself.",
                       "Vincent Van Gogh - \nWhoever loves much, performs much, and can accomplish much, and what is done in love is done well.",
                       "Winston Churchill - \nCourage is the first of human qualities because it is the quality which guarantees all others.",
                       "Oliver Wendell Holmes - The great thing in this world is not so much where you stand, as in what direction you are moving.",
                       "Arthur Schopenhauer - \nEvery truth passes through three stages before it is recognized. In the first, it is ridiculed. In the second, it is opposed. In the third, it is regarded as self evident.",
                       "Jim Rohn - \nEither you run the day, or the day runs you.",
                       "Vince Lombardi - \nThe difference between a successful person and others is not lack of strength not a lack of knowledge but rather a lack of will.",
                       "John F. Kennedy - \nIf not us, who? If not now, when?",
                       "Carl Bard - \nThough no one can go back and make a brand new start, anyone can start from now and make a brand new ending.",
                       "George Bernard Shaw - \nSome men see things as they are and say why – I dream things that never were and say why not.",
                       "William Shakespeare - \nSpeak less than you know; have more than you show.",
                       "Thomas Edison - \nMany of life’s failures are experienced by people who did not realize how close they were to success when they gave up.",
                       "Joe Clark - \nDefeat is not bitter unless you swallow it.",
                       "Larry Winget - Nobody ever wrote down a plan to be broke, fat, lazy, or stupid. Those things are what happen when you don’t have a plan.",
                       "Bomi Chen - Do what makes you happy. :)",
                       "Joshua J. Marine - \nChallenges are what make life interesting and overcoming them is what makes life meaningful.",
                       "Mark Twain - \nKeep away from people who try to belittle your ambitions. Small people always do that, but the really great makes you feel that you, too, can become great.",
                       "Albert Einstein - \nI am thankful for all of those who said NO to me. Its because of them I’m doing it myself.",
                       "Bruce Lee - \nI fear not the man who has practiced 10,000 kicks once, but I fear the man who has practiced one kick 10,000 times.",
                       "John Lennon - \nWhen I was 5 years old, my mother always told me that happiness was the key to life. When I went to school, they asked me what I wanted to be when I grew up. I wrote down ‘happy’. They told me I didn’t understand the assignment, and I told them they didn’t understand life.",
                       "Walt Disney - \nThere is more treasure in books than in all the pirate’s loot on Treasure Island."]

