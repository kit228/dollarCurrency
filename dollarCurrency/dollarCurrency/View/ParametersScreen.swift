//
//  ParametersScreen.swift
//  dollarCurrency
//
//  Created by Вениамин Китченко on 07.08.2021.
//

import UIKit
import UserNotifications // для нотификции, когда установлен флаг проверки валют

protocol UpdateDelegate: class { // делегат для обновления таблицы на первом экране
    func didUpdate(sender: ParametersScreen)
}

class ParametersScreen: UIViewController {
    
    weak var delegate: UpdateDelegate? // делегат для обновления таблицы на первом экране
    
    @IBOutlet weak var moreThanLabel: UILabel!
    @IBOutlet weak var lessThanLabel: UILabel!
    
    
    @IBOutlet weak var moreSegmentControl: UISegmentedControl!
    @IBOutlet weak var lessSegmentControl: UISegmentedControl!
    
    
    @IBOutlet weak var moreThanTextField: UITextField!
    @IBOutlet weak var lessThanTextField: UITextField!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentContols() // настройки сегмент контролов
        setupTextFields() // настройка тектовых полей
        registerForKeyboardNotifications() // регистриуем нотификацию, чтобы знать, когда появляется ил искрывается клавиатура для того, чтобы вместе с ней двигать ScrollView
        setupHideKeyboard() // настраиваем скрытие клавиатуры
        LocalNotificationManager.askPermissionForUserNotifications() // спрашиваем разрешение выводить нотификации
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.delegate?.didUpdate(sender: self) // информируем делегат об изменении
    }
    
    deinit {
        removeKeyboardNotifications() // удаляем обсерверы появления-исчезновения клавиатуры
    }
    
    func registerForKeyboardNotifications() { // для того, чтобы понимать когда появляется клавиатура, узнать ее высоту и двигать  scrrollView
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil) // обсервер появления клаватуры и действия при этом
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil) // обсервер исчещания клавиатуры и дейстия при этом
    }
    
    @objc func keyboardWillShow(_ notification: Notification) { // действие при появлении клавиатуры. Notification нужен, чтобы получить характеристики с этим уведомлением
        let userInfo = notification.userInfo // получаем словарик из Notification
        
        if lessThanTextField.isEditing { // делаем смещение только при нажатии на нижний textField
            if let keyboardFrameSize = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue { // размер фрейма клавиатуры
                scrollView.contentOffset = CGPoint(x: 0, y: keyboardFrameSize.height) // смещаем контент scrollView по высоте клавиатуры
            }
        }
        
    }
    
    @objc func keyboardWillHide() { // действие при скрытии клавиатуры
        scrollView.contentOffset = CGPoint.zero // возвращаем контент scrollView в начальное положение
    }
    
    func removeKeyboardNotifications() { // удаляем обсерверы появления-исчезновения клавиатуры
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupTextFields() {
        // настройка делегата для textField UITextFieldDelegate для вадидации символов
        moreThanTextField.delegate = self
        lessThanTextField.delegate = self
        // записываем установленные числа
        moreThanTextField.text = String(ParametersSettings.parameterMoreThanNeed)
        lessThanTextField.text = String(ParametersSettings.parameterLessThanNeed)
        // чтобы для локалей, где в decimalPad показывается только запятая (а не точка), показывалась полноценная клавиатура numbersAndPunctuation
        self.setCorrectDecimalKeyboard(UITextField: moreThanTextField)
        self.setCorrectDecimalKeyboard(UITextField: lessThanTextField)
    }
    
    func setCorrectDecimalKeyboard(UITextField: UITextField)  { // чтобы для локалей, где в decimalPad показывается только запятая (а не точка), показывалась полноценная клавиатура numbersAndPunctuation
       
        let language = Locale.current.identifier
       
        if (language == "en_GB" || language == "en_US") {
            UITextField.keyboardType = UIKeyboardType.decimalPad
        }
        else {
            UITextField.keyboardType = UIKeyboardType.numbersAndPunctuation
        }
    }
    
    func setupSegmentContols() {
        
        // настраиваем moreSegmentControl
        moreSegmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.black], for: .selected) // ставим цвет текста как черный для выбранного сегмента
        moreSegmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.black], for: .normal) // ставим цвет текста как черный для выбранного сегмента
        moreSegmentControl.backgroundColor = .lightGray // устанавливаем цвет фона
        moreSegmentControl.addTarget(self, action: #selector(moreSegmentAction), for: .valueChanged) // устанавливаем действие для изменения сегмента
        
        // проставляем положение контрола при открытии экрана, а также активность textfield
        if ParametersSettings.comparisonMoreThanNeedIsOn {
            moreSegmentControl.selectedSegmentIndex = 1
            moreSegmentOn(changeSavedOnOrOff: false)
        } else if !ParametersSettings.comparisonMoreThanNeedIsOn {
            moreSegmentControl.selectedSegmentIndex = 0
            moreSegmentOff(changeSavedOnOrOff: false)
        }
        
        
        // настраиваем lessSegmentControl
        lessSegmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.black], for: .selected) // ставим цвет текста как черный для выбранного сегмента
        lessSegmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.black], for: .normal) // ставим цвет текста как черный для выбранного сегмента
        lessSegmentControl.backgroundColor = .lightGray // устанавливаем цвет фона
        lessSegmentControl.addTarget(self, action: #selector(lessSegmentAction), for: .valueChanged) // устанавливаем действие для изменения сегмента
        
        // проставляем положение контрола при открытии экрана, а также активность textfield
        if ParametersSettings.comparisonLessThanNeedIsOn {
            lessSegmentControl.selectedSegmentIndex = 1
            lessSegmentOn(changeSavedOnOrOff: true)
        } else if !ParametersSettings.comparisonMoreThanNeedIsOn {
            lessSegmentControl.selectedSegmentIndex = 0
            lessSegmentOff(changeSavedOnOrOff: false)
        }
    }
    
    @objc func moreSegmentAction() { // действие при изменении сегмента moreSegmentControl
        changeColourAndParameterMoreSegment()
    }
    
    @objc func lessSegmentAction() { // действие при изменении сегмента lessSegmentControl
        changeColourAndParameterLessSegment()
    }
    
    func changeColourAndParameterMoreSegment() {
        if moreSegmentControl.selectedSegmentIndex == 1 {
            moreSegmentOn(changeSavedOnOrOff: true)
        } else if moreSegmentControl.selectedSegmentIndex == 0 {
            moreSegmentOff(changeSavedOnOrOff: true)
        }
    }
    
    func changeColourAndParameterLessSegment() {
        if lessSegmentControl.selectedSegmentIndex == 1 {
            lessSegmentOn(changeSavedOnOrOff: true)
        } else if lessSegmentControl.selectedSegmentIndex == 0 {
            lessSegmentOff(changeSavedOnOrOff: true)
        }
    }
    
    
    func moreSegmentOn(changeSavedOnOrOff: Bool) {
        moreSegmentControl.backgroundColor = .systemGreen
        if changeSavedOnOrOff {
            ParametersSettings.comparisonMoreThanNeedIsOn = true
            CustomOperationsAndConstants.UDefaultsComparisonMoreThanNeedIsOn(bool: true, saveOrGet: .save) // сохраняем в UserDefaults
        }
        moreThanTextField.isEnabled = true
        moreThanTextField.textColor = .label
    }
    func moreSegmentOff(changeSavedOnOrOff: Bool) {
        moreSegmentControl.backgroundColor = .lightGray
        if changeSavedOnOrOff {
            ParametersSettings.comparisonMoreThanNeedIsOn = false
            CustomOperationsAndConstants.UDefaultsComparisonMoreThanNeedIsOn(bool: false, saveOrGet: .save) // сохраняем в UserDefaults
        }
        moreThanTextField.isEnabled = false
        moreThanTextField.textColor = .lightGray
    }
    
    func lessSegmentOn(changeSavedOnOrOff: Bool) {
        lessSegmentControl.backgroundColor = .systemRed
        if changeSavedOnOrOff {
            ParametersSettings.comparisonLessThanNeedIsOn = true
            CustomOperationsAndConstants.UDefaultsComparisonLessThanNeedIsOn(bool: true, saveOrGet: .save) // сохраняем в UserDefaults
        }
        lessThanTextField.isEnabled = true
        lessThanTextField.textColor = .label
    }
    func lessSegmentOff(changeSavedOnOrOff: Bool) {
        lessSegmentControl.backgroundColor = .lightGray
        if changeSavedOnOrOff {
            ParametersSettings.comparisonLessThanNeedIsOn = false
            CustomOperationsAndConstants.UDefaultsComparisonLessThanNeedIsOn(bool: false, saveOrGet: .save) // сохраняем в UserDefaults
        }
        lessThanTextField.isEnabled = false
        lessThanTextField.textColor = .lightGray
    }

}


extension ParametersScreen { // настройки скрытия клавиатуры
    func setupHideKeyboard() { // настраиваем скрытие клавиатуры
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
        moreThanTextField.endEditing(true)
    }
}




extension ParametersScreen: UITextFieldDelegate { // UITextFieldDelegate для textField
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // ввод только цифр
//        let newCharacters = NSCharacterSet(charactersIn: string)
//        return NSCharacterSet.decimalDigits.isSuperset(of: newCharacters as CharacterSet)
        
        
//        // ограничиваем ввод на 8 символов
//        var result = true
//        let maximumLenght = 8
//        if let currentString = textField.text as? NSString {
//            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
//            let replacementIsLegal = newString.length <= maximumLenght // ограничиваем длину
//            result = replacementIsLegal // возвращаем результат в 8 символами
//
//        }
//        return result
        
        
        // ввод только цифр и точки
//        let inverseSet = NSCharacterSet(charactersIn:"0123456789.").inverted
//        let components = string.components(separatedBy: inverseSet)
//        let filtered = components.joined(separator: "")
//        return string == filtered
        
        
        // ввод цифр и одной точки
//        let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
//        let components = string.components(separatedBy: inverseSet)
//        let filtered = components.joined(separator: "")
//
//        if filtered == string {
//            return true
//        } else {
//            if string == "." {
//                let countdots = textField.text!.components(separatedBy:".").count - 1
//                if countdots == 0 {
//                    return true
//                }else{
//                    if countdots > 0 && string == "." {
//                        return false
//                    } else {
//                        return true
//                    }
//                }
//            }else{
//                return false
//            }
//        }
        
        
        // ввод цифр и одной точки
        let maximumLenght = 8
        
        let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: "")

        if filtered == string {
            var result = true
            if let currentString = textField.text as? NSString {
                let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
                let replacementIsLegal = newString.length <= maximumLenght // ограничиваем длину
                result = replacementIsLegal // возвращаем результат в 8 символами
            }
            return result
        } else {
            if string == "." {
                let countdots = textField.text!.components(separatedBy:".").count - 1
                if countdots == 0 {
                    return true
                }else{
                    if countdots > 0 && string == "." {
                        return false
                    } else {
                        return true
                    }
                }
            }else{
                return false
            }
        }
        
    }
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.view.endEditing(true)
//        return false
//    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) { // действие, когда завершено редактирование
        //textField.resignFirstResponder()
        
        // вместо пустоты "" и точки записываем нули, а также сохраняем значение. Также проверка на то, чтобы parameterLessThanNeed и parameterMoreThanNeed были неодинаковы
        if textField == moreThanTextField {
            if moreThanTextField.text == "" || moreThanTextField.text == "." || lessThanTextField.text == "-" {
                moreThanTextField.text = "0.00"
                //print("записываем в parameterMoreThanNeed 0.00")
                ParametersSettings.parameterMoreThanNeed = 0.00
                CustomOperationsAndConstants.UDefaultsParameterMoreThanNeed(doubleValue: 0.00, saveOrGet: .save) // сохраняем в UserDefaults
            }
            if ParametersSettings.comparisonLessThanNeedIsOn {
                if let textFromField = moreThanTextField.text { // разворачиваем переменную
                    if var doubleValueToSave: Double = Double(textFromField) {
                        if doubleValueToSave <= ParametersSettings.parameterLessThanNeed { // делаем так, чтобы два поля не могли быть одинаковыми
                            doubleValueToSave = round((ParametersSettings.parameterLessThanNeed + 0.1) * 10000) / 10000 // прибавляем 0.1 и ограничиваем пять цифр после запятой
                            moreThanTextField.text = String(doubleValueToSave)
                        }
                        //print("записываем в parameterMoreThanNeed \(doubleValueToSave)")
                        ParametersSettings.parameterMoreThanNeed = doubleValueToSave // сохраняем значение
                        CustomOperationsAndConstants.UDefaultsParameterMoreThanNeed(doubleValue: doubleValueToSave, saveOrGet: .save) // сохраняем в UserDefaults
                    }
                }
            } else if let textFromField = moreThanTextField.text { // разворачиваем переменную
                if var doubleValueToSave: Double = Double(textFromField) {
                    //print("записываем в parameterMoreThanNeed \(doubleValueToSave)")
                    ParametersSettings.parameterMoreThanNeed = doubleValueToSave // сохраняем значение
                    CustomOperationsAndConstants.UDefaultsParameterMoreThanNeed(doubleValue: doubleValueToSave, saveOrGet: .save) // сохраняем в UserDefaults
                }
            }
            
        }
        
        else if textField == lessThanTextField {
            
            if lessThanTextField.text == "" || lessThanTextField.text == "." || lessThanTextField.text == "-" {
                lessThanTextField.text = "0.00"
                //print("записываем в parameterLessThanNeed 0.00")
                ParametersSettings.parameterLessThanNeed = 0.00
                CustomOperationsAndConstants.UDefaultsParameterLessThanNeed(doubleValue: 0.00, saveOrGet: .save) // сохраняем в UserDefaults
            }
            if ParametersSettings.comparisonMoreThanNeedIsOn {
                if let textFromField = lessThanTextField.text { // разворачиваем переменную
                    if var doubleValueToSave: Double = Double(textFromField) {
                        if doubleValueToSave >= ParametersSettings.parameterMoreThanNeed { // делаем так, чтобы два поля не могли быть одинаковыми
                            doubleValueToSave = round((ParametersSettings.parameterMoreThanNeed - 0.1) * 10000) / 10000 // отнимаем 0.1 и ограничиваем пять цифр после запятой
                            lessThanTextField.text = String(doubleValueToSave)
                        }
                        //print("записываем в parameterLessThanNeed \(doubleValueToSave)")
                        ParametersSettings.parameterLessThanNeed = doubleValueToSave // сохраняем значение
                        CustomOperationsAndConstants.UDefaultsParameterLessThanNeed(doubleValue: doubleValueToSave, saveOrGet: .save) // сохраняем в UserDefaults
                    }
                }
            } else if let textFromField = lessThanTextField.text { // разворачиваем переменную
                if var doubleValueToSave: Double = Double(textFromField) {
                    //print("записываем в parameterLessThanNeed \(doubleValueToSave)")
                    ParametersSettings.parameterLessThanNeed = doubleValueToSave // сохраняем значение
                    CustomOperationsAndConstants.UDefaultsParameterLessThanNeed(doubleValue: doubleValueToSave, saveOrGet: .save) // сохраняем в UserDefaults
                }
            }

        }
        
    }
    
    
}
