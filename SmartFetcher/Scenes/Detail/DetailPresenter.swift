//
//  DetailPresenter.swift
//  SmartFetcher
//
//  Created by Raymond Law on 9/1/17.
//  Copyright (c) 2017 Clean Swift LLC. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

// MARK: - Presentation logic

protocol DetailPresentationLogic
{
  func presentEvent(response: Detail.ShowEvent.Response)
}

// MARK: - Presenter

class DetailPresenter: DetailPresentationLogic
{
  weak var viewController: DetailDisplayLogic?
  
  // MARK: - Show event
  
  func presentEvent(response: Detail.ShowEvent.Response)
  {
    let viewModel = Detail.ShowEvent.ViewModel(event: response.event.timestamp.description)
    viewController?.displayEvent(viewModel: viewModel)
  }
}
