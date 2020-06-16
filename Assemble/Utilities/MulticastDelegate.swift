//  Assemble
//  Created by David Spry on 25/4/20.
//  Copyright © 2020 David Spry. All rights reserved.

import Foundation

/// A store of weak references to objects for the purpose of delegation.
///
/// - Author: 'Klemen'
/// - Note: Source: <https://stackoverflow.com/a/44697868/9611538>

class MulticastDelegate <T>
{
    private let delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()

    /// Add a delegate to the `MulticastDelegate` store.
    ///
    /// - Parameter delegate: An object who should be delegated to by the owner of the `MulticastDelegate` store
    /// - Complexity: O(1) in the best and (amortised) average cases. O(n) in the worst case.

    func add(_ delegate: T) {
        delegates.add(delegate as AnyObject)
    }
    
    /// Remove a delegate from the `MulticastDelegate` store.
    ///
    /// - Parameter delegate: The object who should be removed from the `MulticastDelegate` store
    /// - Complexity: O(1) in the best and average cases. O(n) in the worst case.

    func remove(_ delegate: T) {
        delegates.allObjects.reversed().forEach {
            if $0 === delegate as AnyObject {
                delegates.remove($0)
            }
        }
    }

    /// For each object in the `MulticastDelegate` store, execute a closure in which the object is the parameter.
    ///
    /// - Parameter invocation: A closure in which an object, `T`, is the parameter, to be invoked upon each object
    /// in the `MulticastDelegate` store.
    ///
    /// For example, the following closure invokes `meow()` on each object in the store.
    /// ~~~
    /// let cats = MulticastDelegate<Cat>()
    /// cats.invoke({ cat in cat.meow() })
    /// ~~~

    func invoke(_ invocation: (T) -> ()) {
        delegates.allObjects.reversed().forEach {
            invocation($0 as! T)
        }
    }

}
