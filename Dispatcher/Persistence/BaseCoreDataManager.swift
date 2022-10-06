import UIKit
import CoreData

class BaseCoreDataManager {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    func saveCoreDataChanges() -> String? {
        do {
            try context.save()
            return nil
        } catch {
            return("Error saving context, \(error.localizedDescription)")
        }
    }
    
    
    func clearCoreDataMemory() {
        let entities = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.managedObjectModel.entities
        for entity in entities {
            delete(entityName: entity.name!)
        }
    }
    
    
    private func delete(entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.execute(deleteRequest)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
}
