//
//  NewPostForm.swift
//  Socialcademy
//
//  Created by John Royal on 10/12/21.
//

import SwiftUI

// MARK: - NewPostForm

struct NewPostForm: View {
    @StateObject var viewModel: NewPostFormViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Title") {
                    TextField("Title", text: $viewModel.title)
                }
                Section("Content") {
                    TextEditor(text: $viewModel.content)
                        .multilineTextAlignment(.leading)
                }
                ChooseImageSection(selection: $viewModel.image)
                SubmitButton(action: viewModel.submitPost)
            }
            .navigationTitle("New Post")
        }
        .onSubmit(viewModel.submitPost)
        .disabled(viewModel.isLoading)
        .alert("Error", isPresented: $viewModel.hasError, actions: {}) {
            Text("Sorry, something went wrong while creating your post.")
        }
        .onChange(of: viewModel.didSubmit) { didSubmit in
            guard didSubmit else { return }
            dismiss()
        }
    }
}

// MARK: - ChooseImageSection

private extension NewPostForm {
    struct ChooseImageSection: View {
        @Binding var selection: UIImage?
        @State private var showChooseImageSource = false
        @State private var imageSourceType: ImagePickerView.SourceType?
        
        var body: some View {
            Section("Image") {
                if let image = selection {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                    Button("Change Image", action: {
                        showChooseImageSource = true
                    })
                } else {
                    Button("Select Image", action: {
                        showChooseImageSource = true
                    })
                }
            }
            .confirmationDialog("Choose Image", isPresented: $showChooseImageSource) {
                Button("Choose from Library", action: {
                    imageSourceType = .photoLibrary
                })
                Button("Take Photo", action: {
                    imageSourceType = .camera
                })
                if selection != nil {
                    Button("Remove Image", role: .destructive, action: {
                        selection = nil
                    })
                }
            }
            .sheet(item: $imageSourceType) {
                ImagePickerView(sourceType: $0, selection: $selection)
            }
        }
    }
}

// MARK: - SubmitButton

private extension NewPostForm {
    struct SubmitButton: View {
        let action: () -> Void
        
        @Environment(\.isEnabled) private var isEnabled
        
        var body: some View {
            Button(action: action) {
                Group {
                    if isEnabled {
                        Text("Submit Post")
                            .fontWeight(.semibold)
                    } else {
                        ProgressView()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
            }
            .listRowBackground(Color.accentColor)
            .animation(.default, value: isEnabled)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct NewPostForm_Previews: PreviewProvider {
    static var previews: some View {
        NewPostForm(viewModel: NewPostFormViewModel(user: User.testUser, submitAction: { _ in }))
    }
}
#endif
