//
//  ViewController.swift
//  MetronomeAVA_PlaySetup
//
//  Created by Андрей Андриянов on 03.11.2024.
//

import UIKit

class ViewController: UIViewController, PickerDelegate {
    
    var metronome = Metronome()
    let pickerView = UIPickerView()
    var slider = UISlider()
    var pickerData: [String] = []
    
    //   MARK: - Create stack view
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
//    Create struct later
    lazy var beatImageArray: [UIImageView] = [
        createImageView(),
        createImageView(),
        createImageView(),
        createImageView(),
        createImageView(),
        createImageView(),
        createImageView(),
        createImageView()
    ]
    func addArrageSubviews() {
        stackView.addArrangedSubview(beatImageArray[0])
        stackView.addArrangedSubview(beatImageArray[1])
        stackView.addArrangedSubview(beatImageArray[2])
        stackView.addArrangedSubview(beatImageArray[3])
        stackView.addArrangedSubview(beatImageArray[4])
        stackView.addArrangedSubview(beatImageArray[5])
        stackView.addArrangedSubview(beatImageArray[6])
        stackView.addArrangedSubview(beatImageArray[7])
    }
    let imageBackground = UIImage(systemName: "stop.fill")
    let image2 = UIImage(systemName: "stop")
    
    func createImageView() -> UIImageView {
        let imageView = UIImageView(image: image2)
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.tintColor = UIColor(#colorLiteral(red: 0.6155465245, green: 0.596773684, blue: 0.5478830338, alpha: 1))
        return imageView
    }
    //    MARK: Elements
    
   
    var timeSignButton: UIButton = {
        let timeSignButton = UIButton()
    timeSignButton.backgroundColor = UIColor(#colorLiteral(red: 0.6155465245, green: 0.596773684, blue: 0.5478830338, alpha: 1))
    timeSignButton.tintColor = .systemGray
    timeSignButton.setTitle("4/4", for: .normal)
    timeSignButton.layer.cornerRadius = 10
    timeSignButton.isHighlighted = true
        timeSignButton.translatesAutoresizingMaskIntoConstraints = false
        return timeSignButton
    }()
    var startButton: UIButton = {
        let startButton = UIButton()
        startButton.backgroundColor = .systemGreen
        startButton.tintColor = .systemGray
        startButton.setTitle("START", for: .normal)
        startButton.layer.cornerRadius = 10
        startButton.isHighlighted = true
        startButton.translatesAutoresizingMaskIntoConstraints = false
        return startButton
    }()
    
    var tapTempoButton: UIButton = {
        let tapTempoButton = UIButton()
        tapTempoButton.backgroundColor = UIColor(#colorLiteral(red: 0.6155465245, green: 0.596773684, blue: 0.5478830338, alpha: 1))
        tapTempoButton.tintColor = .systemGray
        tapTempoButton.setTitle("TAP", for: .normal)
        tapTempoButton.layer.cornerRadius = 10
        tapTempoButton.isHighlighted = true
        tapTempoButton.translatesAutoresizingMaskIntoConstraints = false
        return tapTempoButton
    }()
    var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "background")
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.isIdleTimerDisabled = true
        setupImageView()
        setConstraints()

        pickerView.backgroundColor = .lightGray
        pickerView.alpha = 0.9
        pickerView.layer.cornerRadius = 80
        
//        setupPicker()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        setSliderDefault()

        addArrageSubviews()
       
        pickerView.selectRow(Int(slider.value - 20), inComponent: 0, animated: true)
        
        startButton.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        timeSignButton.addTarget(self, action: #selector(timeSignButtonTap), for: .touchUpInside)
        tapTempoButton.addTarget(self, action: #selector(tapTempoButtonTap), for: .touchDown)
        
        slider.addTarget(self, action: #selector(changedBpm), for: .allEvents)
        
        self.updateBeatImage(Metronome.topNum)
        
        metronome.clickForAnimate = { (interval) in
            self.cancelBeatImageAnimation()
            self.animateBeatImage()
        }
    }
   
    //    MARK: - Setup background image
    func setupImageView() {
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    //    MARK: - Slider colors and value
    func setSliderDefault() {
        slider.tintColor = UIColor(#colorLiteral(red: 0.3821307421, green: 0.3722137213, blue: 0.3333640099, alpha: 1))
        slider.thumbTintColor = UIColor(#colorLiteral(red: 0.3801537156, green: 0.2612983584, blue: 0, alpha: 1))
        slider.maximumTrackTintColor = UIColor(#colorLiteral(red: 0.6155465245, green: 0.596773684, blue: 0.5478830338, alpha: 1))
        slider.minimumValue = metronome.minBpm
        slider.maximumValue = metronome.maxBpm
        slider.value = metronome.bpm
    }
    //    MARK: - Action change slider value
    @objc func changedBpm() {
        //        Проверить верность использования
        metronome.bpm = slider.value
        DispatchQueue.main.async {
            self.pickerView.selectRow(Int(self.slider.value - 20), inComponent: 0, animated: true)
        }
    }
    //    MARK: - Action button
    @objc func buttonTap() {
//        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.cancelBeatImageAnimation()
//        }
        if metronome.isRunning == true {
            metronome.isRunning = false
            startButton.backgroundColor = .systemGreen
            startButton.setTitle("START", for: .normal)
        } else {
            metronome.isRunning = true
            startButton.backgroundColor = .systemRed
            startButton.setTitle("STOP", for: .normal)
            }
    }
    @objc func timeSignButtonTap() {
        let pickerViewController = PickerViewController()
        pickerViewController.delegate = self
        if let sheet = pickerViewController.sheetPresentationController {
            sheet.detents = [ .medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 80
            }
        present(pickerViewController, animated: true)
    }

    
    var lastTapTime: TimeInterval?
    @objc func tapTempoButtonTap() {
        let currentTime = Date().timeIntervalSince1970
        // Если есть предыдущее нажатие, вычисляем интервал
        if let lastTap = lastTapTime {
            let interval = currentTime - lastTap
            print("Время между нажатиями: \(interval) секунд")
            
            // Если прошло больше 2 секунд — сбрасываем массив
            if interval > 2 {
                metronome.saveTapTime.removeAll()
                print("Tap times reset")
            }
        } else {
            print("Первое нажатие")
        }
        
        // Обновляем lastTapTime и добавляем текущее время в массив
        lastTapTime = currentTime
        metronome.saveTapTime.append(currentTime)

        // Достаточно ли данных для вычисления BPM?
        guard metronome.saveTapTime.count >= 2 else { return }
        
        // Вычисляем BPM
        metronome.calculateTapSum()

            self.slider.value  = self.metronome.bpm
            self.pickerView.selectRow(Int(self.slider.value - 20), inComponent: 0, animated: true)  
    }

    func updateImage() {
        updateBeatImage(Metronome.topNum)
        timeSignButton.setTitle("\(Metronome.topNum)/4", for: .normal)
    }
    
//   Добавить?  0...topNum
    func updateBeatImage(_ topNum: Int) {
        for i in 0...7 {
            beatImageArray[i].isHidden = i < topNum ? false : true
        }
    }
    
    func animateBeatImage() {
            for i in 0..<Metronome.topNum {
                beatImageArray[i].image = image2
                beatImageArray[Metronome.totalBeat].image = imageBackground
            }
        
        Metronome.totalBeat += 1
        if Metronome.totalBeat >= Metronome.topNum {
            Metronome.totalBeat = 0
        }
    }
    //    MARK: - Cancel animation
//Delete
    func cancelBeatImageAnimation() {
        for i in 0...7 {
            beatImageArray[i].image = image2
        }
    }
    
//    MARK: - SetConstraints
    func setConstraints() {
        view.addSubview(stackView)
        view.addSubview(pickerView)
        view.addSubview(slider)
        view.addSubview(startButton)
        view.addSubview(timeSignButton)
        view.addSubview(tapTempoButton)
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 9),
            pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -9),
            pickerView.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -50),
            
            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            slider.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150),
            
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 30),
            startButton.heightAnchor.constraint(equalToConstant: 60),
            startButton.widthAnchor.constraint(equalToConstant: 150),
            
            timeSignButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timeSignButton.centerYAnchor.constraint(equalTo: startButton.centerYAnchor),
            timeSignButton.heightAnchor.constraint(equalToConstant: 60),
            timeSignButton.widthAnchor.constraint(equalToConstant: 60),
            
            tapTempoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tapTempoButton.centerYAnchor.constraint(equalTo: startButton.centerYAnchor),
            tapTempoButton.heightAnchor.constraint(equalToConstant: 60),
            tapTempoButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
}

//    MARK: - Extensions
extension ViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerData = (Int(20)...Int(200)).map { String($0) }
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        let pickerViewHeight: CGFloat = 150
        let numberOfVisibleRows: CGFloat = 2
            return pickerViewHeight / numberOfVisibleRows
        }
}

extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        slider.value = Float(row + 20)
        metronome.bpm = Float(row + 20)
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()
            if let view = view as? UILabel { label = view }
        label.font = .systemFont(ofSize: 60, weight: .bold)
        label.text =  pickerData[row]
        label.textColor = UIColor(#colorLiteral(red: 0.1340290308, green: 0.1086466387, blue: 4.684161468e-05, alpha: 1))
        label.alpha = 0.9
        label.textAlignment = .center
            return label
    }
}




