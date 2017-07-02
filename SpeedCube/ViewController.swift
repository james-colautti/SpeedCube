//
//  ViewController.swift
//  SpeedCube
//
//  Created by James on 2016-10-10.
//  Copyright © 2016 James Colautti. All rights reserved.
//

import UIKit

extension Int
{
    var degreesToRadians: CGFloat { return CGFloat(self) * .pi / 180 }
}

extension FloatingPoint
{
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

enum TileColor: Int
{
    case white = 0
    case yellow = 1
    case red = 2
    case orange = 3
    case green = 4
    case blue = 5
}

struct Cube
{
    var size: Int = 0
    var top: [[TileColor]] = [[TileColor.white]]
    var bottom: [[TileColor]] = [[TileColor.white]]
    var left: [[TileColor]] = [[TileColor.white]]
    var right: [[TileColor]] = [[TileColor.white]]
    var front: [[TileColor]] = [[TileColor.white]]
    var back: [[TileColor]] = [[TileColor.white]]
}

class ViewController: UIViewController
{

    var cube: Cube!
    @IBOutlet weak var outputTextView: UITextView!
    @IBOutlet weak var topFaceView: UIView!
    @IBOutlet weak var bottomFaceView: UIView!
    @IBOutlet weak var leftFaceView: UIView!
    @IBOutlet weak var rightFaceView: UIView!
    @IBOutlet weak var frontFaceView: UIView!
    @IBOutlet weak var backFaceView: UIView!
    
    //Reverse face views not used
    @IBOutlet weak var topFaceViewReverse: UIView!
    @IBOutlet weak var bottomFaceViewReverse: UIView!
    @IBOutlet weak var leftFaceViewReverse: UIView!
    @IBOutlet weak var rightFaceViewReverse: UIView!
    @IBOutlet weak var frontFaceViewReverse: UIView!
    @IBOutlet weak var backFaceViewReverse: UIView!
    
    var selectedFace: UIView!
    @IBOutlet weak var topFaceButton: UIButton!
    @IBOutlet weak var bottomFaceButton: UIButton!
    @IBOutlet weak var leftFaceButton: UIButton!
    @IBOutlet weak var rightFaceButton: UIButton!
    @IBOutlet weak var frontFaceButton: UIButton!
    @IBOutlet weak var backFaceButton: UIButton!
    
    @IBOutlet weak var settingsPanelBottomLayoutContstraint: NSLayoutConstraint!
    @IBOutlet weak var controlPanel: UIView!
    
    var swapState = false
    @IBOutlet weak var topPanelLabel: UILabel!
    @IBOutlet weak var bottomPanelLabel: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    var isTiming = false
    var timerCounter = 0
    var timer: Timer!
    
    @IBOutlet weak var scrambleCountLabel: UILabel!
    @IBOutlet weak var scrambleCountStepper: UIStepper!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        newCube(size:3)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        drawCube()
        writeOutCube()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Manage Cube
    func newCube(size: Int)
    {
        cube = Cube()
        cube.size = size
        cube.top = Array(repeating: Array(repeating: TileColor.white, count: size), count: size)
        cube.bottom = Array(repeating: Array(repeating: TileColor.yellow, count: size), count: size)
        cube.left = Array(repeating: Array(repeating: TileColor.red, count: size), count: size)
        cube.right = Array(repeating: Array(repeating: TileColor.orange, count: size), count: size)
        cube.front = Array(repeating: Array(repeating: TileColor.blue, count: size), count: size)
        cube.back = Array(repeating: Array(repeating: TileColor.green, count: size), count: size)
        selectedFace = frontFaceView;
    }
    
    @IBAction func pressedToResetCube(_ sender: Any)
    {
        resetCube()
    }
    
    func resetCube()
    {
        newCube(size:3)
        drawCube()
        writeOutCube()
        resetTimer()
    }
    
    //incomplete -- unused
    @IBAction func swapViewsButtonPressed(_ sender: Any)
    {
        swapState = !swapState
        
        if swapState == true
        {
            topPanelLabel.text = "Back"
            bottomPanelLabel.text = "Front"
        }
        else
        {
            topPanelLabel.text = "Front"
            bottomPanelLabel.text = "Back"
        }
        
        swap(&leftFaceView, &rightFaceView)
        swap(&frontFaceView, &backFaceView)
        
        swap(&leftFaceViewReverse, &rightFaceViewReverse)
        swap(&frontFaceViewReverse, &backFaceViewReverse)
        
        drawCube()
        writeOutCube()
    }
    
    @IBAction func scrambleCubePressed(_ sender: Any)
    {
        resetTimer()
        
        scrambleCube(remaining: Int(scrambleCountStepper.value));
    }
    
    func scrambleCube(remaining: Int)
    {
        let side = arc4random() % 6
        switch side {
        case 0:
            self.selectedFace = self.topFaceView;
        case 1:
            self.selectedFace = self.bottomFaceView;
        case 2:
            self.selectedFace = self.leftFaceView;
        case 3:
            self.selectedFace = self.rightFaceView;
        case 4:
            self.selectedFace = self.frontFaceView;
        case 5:
            self.selectedFace = self.backFaceView;
        default:
            self.selectedFace = self.frontFaceView;
        }
        
        let dir = arc4random() % 2
        switch dir {
        case 0:
            self.pressedToRotateClockwise(nil)
        case 1:
            self.pressedToRotateCounterClockwise(nil)
        default:
            self.pressedToRotateClockwise(nil)
        }
        
        if (remaining > 1)
        {
            let when = DispatchTime.now() + 0.1
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.scrambleCube(remaining: remaining - 1)
            }
        }
        else
        {
            self.isTiming = true
            self.startTimer()
        }
    }
    
    @IBAction func scrambleCountChanged(_ sender: UIStepper)
    {
        scrambleCountLabel.text = String(format:"%.0f", scrambleCountStepper.value)
    }
    
    func testCube()
    {
        for i in 0..<3
        {
            for j in 0..<3
            {
                if (cube.top[i][j] != cube.top[2][2] ||
                    cube.bottom[i][j] != cube.bottom[2][2] ||
                    cube.left[i][j] != cube.left[2][2] ||
                    cube.right[i][j] != cube.right[2][2] ||
                    cube.front[i][j] != cube.front[2][2] ||
                    cube.back[i][j] != cube.back[2][2])
                {
                    return;
                }
            }
        }
        
        endTimer()
    }
    
    func writeOutCube()
    {
        //outputTextView.text = "Top:\n \(cube.top) \nBottom:\n \(cube.bottom) \nLeft:\n \(cube.left) \nRight:\n \(cube.right) \nFront:\n \(cube.front) \nBack:\n \(cube.back)"
    }
    
    // MARK: Manage Timer
    func resetTimer()
    {
        if timer != nil
        {
            timer.invalidate()
        }
        timerLabel.text = "00:00.000"
        timerCounter = 0
        isTiming = false
        timerLabel.textColor = UIColor.black
    }
    
    func startTimer()
    {
        resetTimer()
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
    }
    
    func runTimer()
    {
        timerCounter += 1
        let minutes = timerCounter / 100 / 60
        let seconds: Double = (Double(timerCounter) / 100.0).truncatingRemainder(dividingBy:60.0)
        if seconds < 10
        {
            if minutes < 10
            {
                timerLabel.text = String.init(format: "0%d:0%.3f", minutes, seconds)
            }
            else
            {
                timerLabel.text = String.init(format: "%d:0%.3f", minutes, seconds)
            }
        }
        else
        {
            if minutes < 10
            {
                timerLabel.text = String.init(format: "0%d:%.3f", minutes, seconds)
            }
            else
            {
                timerLabel.text = String.init(format: "%d:%.3f", minutes, seconds)
            }
        }
    }
    
    func endTimer()
    {
        if timer != nil
        {
            timer.invalidate()
        }
        isTiming = false
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(flashTimer), userInfo: nil, repeats: true)
    }
    
    func flashTimer()
    {
        if timerLabel.textColor == UIColor.black
        {
            timerLabel.textColor = UIColor.white
        }
        else
        {
            timerLabel.textColor = UIColor.black
        }
    }
    
    // MARK: Control GUI
    @IBAction func panSettingsPanel(_ sender: UIPanGestureRecognizer)
    {
        if sender.state == .changed
        {
            let point = sender.location(in: self.view)
            var yPos = (self.view.frame.size.height - point.y) - (sender.view!.frame.size.height / 2)
            
            if yPos < 0
            {
                yPos = 0
            }
            else if yPos > controlPanel.frame.size.height + 51
            {
                yPos = controlPanel.frame.size.height + 51
            }
            
            settingsPanelBottomLayoutContstraint.constant = yPos
        }
        else if sender.state == .ended
        {
            let point = sender.location(in: self.view)
            var yPos = (self.view.frame.size.height - point.y) - (sender.view!.frame.size.height / 2)
            
            if yPos < 0
            {
                yPos = 0
            }
            else if yPos > controlPanel.frame.size.height
            {
                yPos = controlPanel.frame.size.height
            }
            
            if yPos >= controlPanel.frame.size.height / 2
            {
                settingsPanelBottomLayoutContstraint.constant = controlPanel.frame.size.height + 51
            }
            else
            {
                settingsPanelBottomLayoutContstraint.constant = 0
            }
        }
        
        UIView.animate(withDuration: 0.3) { 
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: Rotate Cube
    @IBAction func pressedToRotateLeft(_ sender: AnyObject)
    {
        rotateCubeLeft()
    }
    
    @IBAction func pressedToRotateRight(_ sender: AnyObject)
    {
        rotateCubeRight()
    }
    
    @IBAction func pressedToRotateUp(_ sender: AnyObject)
    {
        rotateCubeUp()
    }
    
    @IBAction func pressedToRotateDown(_ sender: AnyObject)
    {
        rotateCubeDown()
    }
    
    @IBAction func selectedFace(_ sender: UIButton)
    {
        switch sender {
        case topFaceButton:
            selectedFace = topFaceView;
        case bottomFaceButton:
            selectedFace = bottomFaceView;
        case leftFaceButton:
            selectedFace = leftFaceView;
        case rightFaceButton:
            selectedFace = rightFaceView;
        case frontFaceButton:
            selectedFace = frontFaceView;
        case backFaceButton:
            selectedFace = backFaceView;
        default:
            selectedFace = frontFaceView;
        }
    }
    
    @IBAction func pressedToRotateClockwise(_ sender: AnyObject!)
    {
        switch selectedFace {
        case topFaceView:
            rotateTopFaceClockwise()
        case bottomFaceView:
            rotateBottomFaceClockwise()
        case leftFaceView:
            rotateLeftFaceClockwise()
        case rightFaceView:
            rotateRightFaceClockwise()
        case frontFaceView:
            rotateFrontFaceClockwise()
        case backFaceView:
            rotateBackFaceClockwise()
        default:
            break;
        }
    }
    
    @IBAction func pressedToRotateCounterClockwise(_ sender: AnyObject!)
    {
        switch selectedFace {
        case topFaceView:
            rotateTopFaceCounterClockwise()
        case bottomFaceView:
            rotateBottomFaceCounterClockwise()
        case leftFaceView:
            rotateLeftFaceCounterClockwise()
        case rightFaceView:
            rotateRightFaceCounterClockwise()
        case frontFaceView:
            rotateFrontFaceCounterClockwise()
        case backFaceView:
            rotateBackFaceCounterClockwise()
        default:
            break;
        }
    }
    
    func rotateCubeLeft()
    {
        let temp = cube.front
        cube.front = cube.right
        cube.right = cube.back
        cube.back = cube.left
        cube.left = temp
        
        rotateArrayClockwise(&cube.top)
        rotateArrayCounterClockwise(&cube.bottom)
        
        drawCube()
        writeOutCube()
    }
    
    func rotateCubeRight()
    {
        let temp = cube.front
        cube.front = cube.left
        cube.left = cube.back
        cube.back = cube.right
        cube.right = temp
        
        rotateArrayCounterClockwise(&cube.top)
        rotateArrayClockwise(&cube.bottom)
        drawCube()
        writeOutCube()
    }
    
    func rotateCubeUp()
    {
        let temp = cube.front
        cube.front = cube.bottom
        cube.bottom = cube.back
        cube.back = cube.top
        cube.top = temp
        
        rotateArrayClockwise(&cube.right)
        rotateArrayCounterClockwise(&cube.left)
        
        drawCube()
        writeOutCube()
    }
    
    func rotateCubeDown()
    {
        let temp = cube.front
        cube.front = cube.top
        cube.top = cube.back
        cube.back = cube.bottom
        cube.bottom = temp
        
        rotateArrayCounterClockwise(&cube.right)
        rotateArrayClockwise(&cube.left)
        
        drawCube()
        writeOutCube()
    }
    
    func rotateArrayClockwise(_ face: inout [[TileColor]])
    {
        let temp = face
        for i in 0..<cube.size
        {
            for j in 0..<cube.size
            {
                face[i][j] = temp[cube.size - j - 1][i]
            }
        }
    }
    
    func rotateArrayCounterClockwise(_ face: inout [[TileColor]])
    {
        let temp = face
        for i in 0..<cube.size
        {
            for j in 0..<cube.size
            {
                face[i][j] = temp[j][cube.size - i - 1]
            }
        }
    }
    
    // MARK: Rotate Faces
    func rotateTopFaceClockwise()
    {
        rotateArrayClockwise(&cube.top)
        
        var temp = [cube.front[0][0], cube.front[0][1], cube.front[0][2]]
        cube.front[0][0] = cube.right[0][0]
        cube.front[0][1] = cube.right[0][1]
        cube.front[0][2] = cube.right[0][2]
        cube.right[0][0] = cube.back[0][0]
        cube.right[0][1] = cube.back[0][1]
        cube.right[0][2] = cube.back[0][2]
        cube.back[0][0] = cube.left[0][0]
        cube.back[0][1] = cube.left[0][1]
        cube.back[0][2] = cube.left[0][2]
        cube.left[0][0] = temp[0]
        cube.left[0][1] = temp[1]
        cube.left[0][2] = temp[2]
        
        updateCube()
    }
    
    func rotateTopFaceCounterClockwise()
    {
        rotateArrayCounterClockwise(&cube.top)
        
        var temp = [cube.front[0][0], cube.front[0][1], cube.front[0][2]]
        cube.front[0][0] = cube.left[0][0]
        cube.front[0][1] = cube.left[0][1]
        cube.front[0][2] = cube.left[0][2]
        cube.left[0][0] = cube.back[0][0]
        cube.left[0][1] = cube.back[0][1]
        cube.left[0][2] = cube.back[0][2]
        cube.back[0][0] = cube.right[0][0]
        cube.back[0][1] = cube.right[0][1]
        cube.back[0][2] = cube.right[0][2]
        cube.right[0][0] = temp[0]
        cube.right[0][1] = temp[1]
        cube.right[0][2] = temp[2]
        
        updateCube()
    }
    
    func rotateBottomFaceClockwise()
    {
        rotateArrayClockwise(&cube.bottom)
        
        var temp = [cube.front[2][0], cube.front[2][1], cube.front[2][2]]
        cube.front[2][0] = cube.left[2][0]
        cube.front[2][1] = cube.left[2][1]
        cube.front[2][2] = cube.left[2][2]
        cube.left[2][0] = cube.back[2][0]
        cube.left[2][1] = cube.back[2][1]
        cube.left[2][2] = cube.back[2][2]
        cube.back[2][0] = cube.right[2][0]
        cube.back[2][1] = cube.right[2][1]
        cube.back[2][2] = cube.right[2][2]
        cube.right[2][0] = temp[0]
        cube.right[2][1] = temp[1]
        cube.right[2][2] = temp[2]
        
        updateCube()
    }
    
    func rotateBottomFaceCounterClockwise()
    {
        rotateArrayCounterClockwise(&cube.bottom)
        
        var temp = [cube.front[2][0], cube.front[2][1], cube.front[2][2]]
        cube.front[2][0] = cube.right[2][0]
        cube.front[2][1] = cube.right[2][1]
        cube.front[2][2] = cube.right[2][2]
        cube.right[2][0] = cube.back[2][0]
        cube.right[2][1] = cube.back[2][1]
        cube.right[2][2] = cube.back[2][2]
        cube.back[2][0] = cube.left[2][0]
        cube.back[2][1] = cube.left[2][1]
        cube.back[2][2] = cube.left[2][2]
        cube.left[2][0] = temp[0]
        cube.left[2][1] = temp[1]
        cube.left[2][2] = temp[2]
        
        updateCube()
    }
    
    func rotateFrontFaceClockwise()
    {
        rotateArrayClockwise(&cube.front)
        
        var temp = [cube.top[2][0], cube.top[2][1], cube.top[2][2]]
        cube.top[2][0] = cube.left[2][2]
        cube.top[2][1] = cube.left[1][2]
        cube.top[2][2] = cube.left[0][2]
        cube.left[2][2] = cube.bottom[0][2]
        cube.left[1][2] = cube.bottom[0][1]
        cube.left[0][2] = cube.bottom[0][0]
        cube.bottom[0][2] = cube.right[0][0]
        cube.bottom[0][1] = cube.right[1][0]
        cube.bottom[0][0] = cube.right[2][0]
        cube.right[0][0] = temp[0]
        cube.right[1][0] = temp[1]
        cube.right[2][0] = temp[2]
        
        updateCube()
    }
    
    func rotateFrontFaceCounterClockwise()
    {
        rotateArrayCounterClockwise(&cube.front)
        
        var temp = [cube.top[2][0], cube.top[2][1], cube.top[2][2]]
        cube.top[2][0] = cube.right[0][0]
        cube.top[2][1] = cube.right[1][0]
        cube.top[2][2] = cube.right[2][0]
        cube.right[0][0] = cube.bottom[0][2]
        cube.right[1][0] = cube.bottom[0][1]
        cube.right[2][0] = cube.bottom[0][0]
        cube.bottom[0][2] = cube.left[2][2]
        cube.bottom[0][1] = cube.left[1][2]
        cube.bottom[0][0] = cube.left[0][2]
        cube.left[2][2] = temp[0]
        cube.left[1][2] = temp[1]
        cube.left[0][2] = temp[2]
        
        updateCube()
    }
    
    func rotateBackFaceClockwise()
    {
        rotateArrayClockwise(&cube.back)
        
        var temp = [cube.top[0][0], cube.top[0][1], cube.top[0][2]]
        cube.top[0][0] = cube.right[0][2]
        cube.top[0][1] = cube.right[1][2]
        cube.top[0][2] = cube.right[2][2]
        cube.right[0][2] = cube.bottom[2][2]
        cube.right[1][2] = cube.bottom[2][1]
        cube.right[2][2] = cube.bottom[2][0]
        cube.bottom[2][2] = cube.left[2][0]
        cube.bottom[2][1] = cube.left[1][0]
        cube.bottom[2][0] = cube.left[0][0]
        cube.left[2][0] = temp[0]
        cube.left[1][0] = temp[1]
        cube.left[0][0] = temp[2]
        
        updateCube()
    }
    
    func rotateBackFaceCounterClockwise()
    {
        rotateArrayCounterClockwise(&cube.back)
        
        var temp = [cube.top[0][0], cube.top[0][1], cube.top[0][2]]
        cube.top[0][0] = cube.left[2][0]
        cube.top[0][1] = cube.left[1][0]
        cube.top[0][2] = cube.left[0][0]
        cube.left[2][0] = cube.bottom[2][2]
        cube.left[1][0] = cube.bottom[2][1]
        cube.left[0][0] = cube.bottom[2][0]
        cube.bottom[2][2] = cube.right[0][2]
        cube.bottom[2][1] = cube.right[1][2]
        cube.bottom[2][0] = cube.right[2][2]
        cube.right[0][2] = temp[0]
        cube.right[1][2] = temp[1]
        cube.right[2][2] = temp[2]
        
        updateCube()
    }
    
    func rotateLeftFaceClockwise()
    {
        rotateArrayClockwise(&cube.left)
        
        var temp = [cube.front[0][0], cube.front[1][0], cube.front[2][0]]
        cube.front[0][0] = cube.top[0][0]
        cube.front[1][0] = cube.top[1][0]
        cube.front[2][0] = cube.top[2][0]
        cube.top[0][0] = cube.back[2][2]
        cube.top[1][0] = cube.back[1][2]
        cube.top[2][0] = cube.back[0][2]
        cube.back[2][2] = cube.bottom[0][0]
        cube.back[1][2] = cube.bottom[1][0]
        cube.back[0][2] = cube.bottom[2][0]
        cube.bottom[0][0] = temp[0]
        cube.bottom[1][0] = temp[1]
        cube.bottom[2][0] = temp[2]
        
        updateCube()
    }
    
    func rotateLeftFaceCounterClockwise()
    {
        rotateArrayCounterClockwise(&cube.left)
        
        var temp = [cube.front[0][0], cube.front[1][0], cube.front[2][0]]
        cube.front[0][0] = cube.bottom[0][0]
        cube.front[1][0] = cube.bottom[1][0]
        cube.front[2][0] = cube.bottom[2][0]
        cube.bottom[0][0] = cube.back[2][2]
        cube.bottom[1][0] = cube.back[1][2]
        cube.bottom[2][0] = cube.back[0][2]
        cube.back[2][2] = cube.top[0][0]
        cube.back[1][2] = cube.top[1][0]
        cube.back[0][2] = cube.top[2][0]
        cube.top[0][0] = temp[0]
        cube.top[1][0] = temp[1]
        cube.top[2][0] = temp[2]
        
        updateCube()
    }
    
    func rotateRightFaceClockwise()
    {
        rotateArrayClockwise(&cube.right)
        
        var temp = [cube.front[0][2], cube.front[1][2], cube.front[2][2]]
        cube.front[0][2] = cube.bottom[0][2]
        cube.front[1][2] = cube.bottom[1][2]
        cube.front[2][2] = cube.bottom[2][2]
        cube.bottom[0][2] = cube.back[2][0]
        cube.bottom[1][2] = cube.back[1][0]
        cube.bottom[2][2] = cube.back[0][0]
        cube.back[2][0] = cube.top[0][2]
        cube.back[1][0] = cube.top[1][2]
        cube.back[0][0] = cube.top[2][2]
        cube.top[0][2] = temp[0]
        cube.top[1][2] = temp[1]
        cube.top[2][2] = temp[2]
        
        updateCube()
    }
    
    func rotateRightFaceCounterClockwise()
    {
        rotateArrayCounterClockwise(&cube.right)
        
        var temp = [cube.front[0][2], cube.front[1][2], cube.front[2][2]]
        cube.front[0][2] = cube.top[0][2]
        cube.front[1][2] = cube.top[1][2]
        cube.front[2][2] = cube.top[2][2]
        cube.top[0][2] = cube.back[2][0]
        cube.top[1][2] = cube.back[1][0]
        cube.top[2][2] = cube.back[0][0]
        cube.back[2][0] = cube.bottom[0][2]
        cube.back[1][0] = cube.bottom[1][2]
        cube.back[0][0] = cube.bottom[2][2]
        cube.bottom[0][2] = temp[0]
        cube.bottom[1][2] = temp[1]
        cube.bottom[2][2] = temp[2]
        
        updateCube()
    }
    
    // MARK: Draw Cube
    func updateCube()
    {
        drawCube()
        writeOutCube()
        testCube()
    }
    
    func drawCube()
    {
        drawFace(cube.top, on: topFaceView)
        drawFace(cube.bottom, on: bottomFaceView)
        drawFace(cube.left, on: leftFaceView)
        drawFace(cube.right, on: rightFaceView)
        drawFace(cube.front, on: frontFaceView)
        drawFace(cube.back, on: backFaceView)
        
//        drawFace(cube.top, on: topFaceViewReverse)
//        drawFace(cube.bottom, on: bottomFaceViewReverse)
//        drawFace(cube.left, on: leftFaceViewReverse)
//        drawFace(cube.right, on: rightFaceViewReverse)
//        drawFace(cube.front, on: frontFaceViewReverse)
//        drawFace(cube.back, on: backFaceViewReverse)
        
        rotateView(topFaceView, angle: -45, x:1.0, y:0.0, z:0.0)
        rotateView(bottomFaceView, angle: 45, x:1.0, y:0.0, z:0.0)
        rotateView(leftFaceView, angle: 45, x:0.0, y:1.0, z:0.0)
        rotateView(rightFaceView, angle: -45, x:0.0, y:1.0, z:0.0)
        
        scaleView(topFaceView, x:1.5, y:1.0, z:1.0)
        scaleView(bottomFaceView, x:1.5, y:1.0, z:1.0)
        scaleView(leftFaceView, x:1.0, y:1.5, z:1.0)
        scaleView(rightFaceView, x:1.0, y:1.5, z:1.0)
        
//        rotateView(topFaceViewReverse, angle: -45, x:1.0, y:0.0, z:0.0)
//        rotateView(bottomFaceViewReverse, angle: 45, x:1.0, y:0.0, z:0.0)
//        rotateView(leftFaceViewReverse, angle: -45, x:0.0, y:1.0, z:0.0)
//        rotateView(rightFaceViewReverse, angle: 45, x:0.0, y:1.0, z:0.0)
        
//        scaleView(topFaceViewReverse, x:1.5, y:1.0, z:1.0)
//        scaleView(bottomFaceViewReverse, x:1.5, y:1.0, z:1.0)
//        scaleView(leftFaceViewReverse, x:1.0, y:1.5, z:1.0)
//        scaleView(rightFaceViewReverse, x:1.0, y:1.5, z:1.0)
    }
    
    func drawFace(_ face:[[TileColor]], on view:UIView)
    {
        view.layer.transform = CATransform3DIdentity
        
        let width = view.frame.size.width / CGFloat(cube.size)
        let height = view.frame.size.height / CGFloat(cube.size)
        
        for i in 0..<cube.size
        {
            for j in 0..<cube.size
            {
                let tile = UIView(frame: CGRect(x: width * CGFloat(j) + 1.0, y: height * CGFloat(i) + 1.0, width: width - 2.0, height: height - 2.0))
                switch face[i][j] {
                case .white:
                    tile.backgroundColor = UIColor.white
                case .yellow:
                    tile.backgroundColor = UIColor.yellow
                case .red:
                    tile.backgroundColor = UIColor.red
                case .orange:
                    tile.backgroundColor = UIColor.orange
                case .green:
                    tile.backgroundColor = UIColor.green
                case .blue:
                    tile.backgroundColor = UIColor.blue
                }
                view.addSubview(tile)
            }
        }
    }
    
    func rotateView(_ view: UIView, angle: CGFloat, x: CGFloat, y: CGFloat, z: CGFloat)
    {
        var transform3D = CATransform3DIdentity
        transform3D.m34 = 1.0 / -50
        transform3D = CATransform3DRotate(transform3D, angle * .pi / 180.0, x, y, z)
        view.layer.transform = transform3D
    }
    
    func scaleView(_ view: UIView, x: CGFloat, y: CGFloat, z: CGFloat)
    {
        var transform3D = CATransform3DIdentity
        transform3D = CATransform3DMakeScale(x, y, z)
        view.layer.transform = CATransform3DConcat(view.layer.transform, transform3D)
    }

}
