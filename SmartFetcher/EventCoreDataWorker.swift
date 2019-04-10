//
//  EventCoreDataWorker.swift
//  SmartFetcher
//
//  Created by Raymond Law on 9/8/17.
//  Copyright (c) 2017 Clean Swift LLC. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import CoreData

// MARK: - Model

extension ManagedEvent
{
  func fromEvent(event: Event)
  {
    timestamp = event.timestamp as Date
  }
  
  func toEvent() -> Event
  {
    return Event(timestamp: timestamp! as Date)
  }
}

// MARK: - Event Core Data protocol

@objc protocol EventCoreDataWorkerDelegate
{
  // MARK: Event update lifecycle
  @objc optional func eventCoreDataWorkerWillUpdate(eventCoreDataWorker: EventCoreDataWorker)
  @objc optional func eventCoreDataWorkerDidUpdate(eventCoreDataWorker: EventCoreDataWorker)
  // MARK: Event section updates
  @objc optional func eventCoreDataWorker(eventCoreDataWorker: EventCoreDataWorker, shouldInsertSection section: IndexSet)
  @objc optional func eventCoreDataWorker(eventCoreDataWorker: EventCoreDataWorker, shouldDeleteSection section: IndexSet)
  @objc optional func eventCoreDataWorker(eventCoreDataWorker: EventCoreDataWorker, shouldUpdateSection section: IndexSet)
  @objc optional func eventCoreDataWorker(eventCoreDataWorker: EventCoreDataWorker, shouldMoveSectionFrom from: IndexSet, to: IndexSet)
  // MARK: Event row updates
  @objc optional func eventCoreDataWorker(eventCoreDataWorker: EventCoreDataWorker, shouldInsertRowAt row: IndexPath)
  @objc optional func eventCoreDataWorker(eventCoreDataWorker: EventCoreDataWorker, shouldDeleteRowAt row: IndexPath)
  @objc optional func eventCoreDataWorker(eventCoreDataWorker: EventCoreDataWorker, shouldUpdateRowAt row: IndexPath, withEvent event: Event)
  @objc optional func eventCoreDataWorker(eventCoreDataWorker: EventCoreDataWorker, shouldMoveRowFrom from: IndexPath, to: IndexPath, withEvent event: Event)
}

// MARK: - Event Core Data worker

final class EventCoreDataWorker: NSObject, EventWorkerAPI
{
  var delegates = [EventCoreDataWorkerDelegate]()
  
  // MARK: - Object lifecycle
  
  static let shared = EventCoreDataWorker()
  private override init() {}
  
  // MARK: - Core Data stack
  
  lazy var persistentContainer: NSPersistentContainer =
    {
      let container = NSPersistentContainer(name: "SmartFetcher")
      container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error as NSError? {
          fatalError("Unresolved error \(error), \(error.userInfo)")
        }
      })
      return container
  }()
  
  var managedObjectContext: NSManagedObjectContext
  {
    return persistentContainer.viewContext
  }
  
  private var _fetchedResultsController: NSFetchedResultsController<ManagedEvent>? = nil
  var fetchedResultsController: NSFetchedResultsController<ManagedEvent>
  {
    if _fetchedResultsController != nil {
      return _fetchedResultsController!
    }
    
    let fetchRequest: NSFetchRequest<ManagedEvent> = ManagedEvent.fetchRequest()
    
    fetchRequest.fetchBatchSize = 20
    let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    _fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: "ManagedEvent")
    _fetchedResultsController!.delegate = self
    
    do {
      try _fetchedResultsController!.performFetch()
    } catch {
      let nserror = error as NSError
      fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
    }
    
    return _fetchedResultsController!
  }
  
  func save()
  {
    if managedObjectContext.hasChanges {
      do {
        try managedObjectContext.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
  // MARK: - Validation
  
  func validate(event: Event) -> Bool
  {
    return true
  }
  
  // MARK: - CRUD operations
  
  func list() -> [Event]
  {
    do {
      try fetchedResultsController.performFetch()
      return fetchedResultsController.fetchedObjects!.map { $0.toEvent() }
    } catch {
      let nserror = error as NSError
      fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
    }
  }
  
  func show(at indexPath: IndexPath) -> Event
  {
    return fetchedResultsController.object(at: indexPath).toEvent()
  }
  
  func new(timestamp: Date) -> Event
  {
    let managedEvent = ManagedEvent(context: managedObjectContext)
    managedEvent.timestamp = timestamp as Date
    return managedEvent.toEvent()
  }
  
  func create(event: Event)
  {
    guard validate(event: event) else { return }
    save()
  }
  
  func edit(at indexPath: IndexPath) -> Event
  {
    return fetchedResultsController.object(at: indexPath).toEvent()
  }
  
  func update(event: Event)
  {
    guard validate(event: event) else { return }
    save()
  }
  
  func delete(at indexPath: IndexPath)
  {
    let managedEvent = fetchedResultsController.object(at: indexPath)
    managedObjectContext.delete(managedEvent)
    save()
  }
  
  // MARK: - Count
  
  func count() -> Int
  {
    return fetchedResultsController.sections![0].numberOfObjects
  }
}

// MARK: - NSFetchedResultsControllerDelegate

extension EventCoreDataWorker: NSFetchedResultsControllerDelegate
{
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
  {
    delegates.forEach { $0.eventCoreDataWorkerWillUpdate?(eventCoreDataWorker: self) }
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType)
  {
    switch type {
    case .insert:
      delegates.forEach { $0.eventCoreDataWorker?(eventCoreDataWorker: self, shouldInsertSection: IndexSet(integer: sectionIndex)) }
    case .delete:
      delegates.forEach { $0.eventCoreDataWorker?(eventCoreDataWorker: self, shouldDeleteSection: IndexSet(integer: sectionIndex)) }
    default:
      return
    }
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
  {
    switch type {
    case .insert:
      delegates.forEach { $0.eventCoreDataWorker?(eventCoreDataWorker: self, shouldInsertRowAt: newIndexPath!) }
    case .delete:
      delegates.forEach { $0.eventCoreDataWorker?(eventCoreDataWorker: self, shouldDeleteRowAt: indexPath!) }
    case .update:
      let event = anObject as! Event
      delegates.forEach { $0.eventCoreDataWorker?(eventCoreDataWorker: self, shouldUpdateRowAt: indexPath!, withEvent: event) }
    case .move:
      let event = anObject as! Event
      delegates.forEach { $0.eventCoreDataWorker?(eventCoreDataWorker: self, shouldMoveRowFrom: indexPath!, to: newIndexPath!, withEvent: event) }
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
  {
    delegates.forEach { $0.eventCoreDataWorkerDidUpdate?(eventCoreDataWorker: self) }
  }
}
