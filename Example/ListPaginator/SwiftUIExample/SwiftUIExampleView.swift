import SwiftUI
import ListPaginator

struct SwiftUIExampleView: View {
    @ObservedObject var paginator = ListPaginator<Repositories, Repository>(strategy: .pageIndex(startingFrom: 1), responseItemsKeyPath: \.repositories)
    
    init() {
        paginator.requestProvider = .publisher({ page in
            return RepositoriesRequest(page: page).request
        })
    }
    
    var body: some View {
        VStack {
            Text("Status: \(paginator.status.description)")
            List(paginator.results) { result in
                Text(result.name)
                    .font(.subheadline)
                    .onAppear {
                        if shouldPaginate(for: result) {
                            paginator.fetchMoreIfNeeded.send()
                        }
                    }
            }
            if case .error = paginator.status {
                Button(action: {
                    paginator.fetchMoreIfNeeded.send()
                }, label: {
                    Text("Retry").frame(height: 40)
                })
            }
        }
    }
    
    private func shouldPaginate(for result: Repository) -> Bool {
        return result.id == paginator.results[paginator.results.count - 3].id && paginator.status.error == nil
    }
}

struct SwiftUIExampleView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIExampleView()
    }
}
