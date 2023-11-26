import Foundation

final class ReadWriteLock {
    private var rwlock = UnsafeMutablePointer<pthread_rwlock_t>.allocate(capacity: 1)

    init() {
        let result = pthread_rwlock_init(rwlock, nil)
        assert(result == 0, "Failed to initialize read-write lock with error: \(result)")
    }

    func read<T>(_ action: () -> T) -> T {
        defer {
            pthread_rwlock_unlock(rwlock)
        }
        pthread_rwlock_rdlock(rwlock)
        return action()
    }

    func write<T>(_ action: () -> T) -> T {
        defer {
            pthread_rwlock_unlock(rwlock)
        }
        pthread_rwlock_wrlock(rwlock)
        return action()
    }

    deinit {
        pthread_rwlock_destroy(rwlock)
        rwlock.deallocate()
    }
}

class ThreadSafeArray<T> {
    private var array: [T] = []
    private let lock = ReadWriteLock()

    func append(_ newElement: T) {
        lock.write {
            array.append(newElement)
        }
    }

    func remove(at index: Int) {
        lock.write {
            if self.array.indices.contains(index) {
                self.array.remove(at: index)
            }
        }
    }
}

extension ThreadSafeArray: RandomAccessCollection {
    typealias Index = Int
    typealias Element = T

    var startIndex: Index {
        return lock.read {
            array.startIndex
        }
    }

    var endIndex: Index {
        return lock.read {
            array.endIndex
        }
    }

    subscript(index: Index) -> Element {
        return lock.read {
            array[index]
        }
    }

    func index(after i: Index) -> Index {
        return lock.read {
            array.index(after: i)
        }
    }
}

