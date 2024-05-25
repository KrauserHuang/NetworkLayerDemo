//
//  ViewController.swift
//  NetworkLayerDemo
//
//  Created by Tai Chin Huang on 2024/4/7.
//

import UIKit

class ViewController: UIViewController {
    
    private var viewModel: ViewModel?
    
//    init(viewModel: ViewModel = ViewModel()) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("Could not create ViewController")
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ViewModel()
        bindToViewModel()
    }
    
    private func bindToViewModel() {
        guard let viewModel = viewModel else { return }
        viewModel.fetchInitData()
    }
}
