import Foundation
import RxSwift
import APIKit

extension Session: ReactiveCompatible {}

extension Reactive where Base: Session {
    func response<T: Request>(_ request: T) -> Single<T.Response> {
        return Single.create { [weak base] observer in
            let task = base?.send(request) { result in
                switch result {
                case let .success(response):
                    observer(.success(response))
                case let .failure(error):
                    observer(.error(error))
                }
            }

            return Disposables.create {
                task?.cancel()
            }
        }
    }
}
