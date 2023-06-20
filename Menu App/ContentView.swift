//
//  ContentView.swift
//  Menu App
//
//  Created by Komal Vanamala on 6/19/23.
//

import SwiftUI

class SheetMananger: ObservableObject {
    @Published var showSheet = false
    @Published var selectedMeal: MealDetail? = nil
}

struct MealItemView: View {
    var meal: Meal
    
    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: meal.strMealThumb)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 240)
                    .clipped()
                    .cornerRadius(12)
            } placeholder: {
                // Placeholder view while the image is being loaded
                ProgressView()
            }
            
            Rectangle()
                .foregroundColor(Color.black.opacity(0.5))
                .blendMode(.overlay)
            
            Text(meal.strMeal)
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()
                .bold()
        }
        .padding()
    }
}

struct MealView: View {
    var meal: MealDetail
    
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: meal.strMealThumb)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "photo")
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity)
                
                Text(meal.strMeal)
                    .font(.title)
                
                Text(getIngredients(meal: meal))
                    .font(.caption)
                    .padding(.horizontal, 8)
                
                Text(meal.strInstructions)
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.top, 2)
            }
        }
    }
}

struct Meal: Decodable {
    let idMeal: String
    let strMeal: String
    let strMealThumb: String
}

struct MealDetail: Decodable {
    let idMeal: String
    let strMeal: String
    let strMealThumb: String
    let strInstructions: String
    let strIngredient1: String
    let strIngredient2: String
    let strIngredient3: String
    let strIngredient4: String
    let strIngredient5: String
    let strIngredient6: String
    let strIngredient7: String
    let strIngredient8: String
    let strIngredient9: String
    let strIngredient10: String
    let strIngredient11: String
    let strIngredient12: String
    let strIngredient13: String
}

struct MealsResponse: Decodable {
    let meals: [Meal]
}

struct MealDetailsResponse: Decodable {
    let meals: [MealDetail]
}

func getIngredients(meal: MealDetail) -> String {
    var ingredients: [String] = [];
    
    if meal.strIngredient1 != "" {
        ingredients.append(meal.strIngredient1.capitalized)
    }
    
    if meal.strIngredient2 != "" {
        ingredients.append(meal.strIngredient2.capitalized)
    }
    
    if meal.strIngredient3 != "" {
        ingredients.append(meal.strIngredient3.capitalized)
    }
    
    if meal.strIngredient4 != "" {
        ingredients.append(meal.strIngredient4.capitalized)
    }
    
    if meal.strIngredient5 != "" {
        ingredients.append(meal.strIngredient5.capitalized)
    }
    
    if meal.strIngredient6 != "" {
        ingredients.append(meal.strIngredient6.capitalized)
    }
    
    if meal.strIngredient7 != "" {
        ingredients.append(meal.strIngredient7.capitalized)
    }
    
    if meal.strIngredient8 != "" {
        ingredients.append(meal.strIngredient8.capitalized)
    }
    
    if meal.strIngredient9 != "" {
        ingredients.append(meal.strIngredient9.capitalized)
    }
    
    if meal.strIngredient10 != "" {
        ingredients.append(meal.strIngredient10.capitalized)
    }
    
    if meal.strIngredient11 != "" {
        ingredients.append(meal.strIngredient11.capitalized)
    }
    
    if meal.strIngredient12 != "" {
        ingredients.append(meal.strIngredient12.capitalized)
    }
    
    if meal.strIngredient13 != "" {
        ingredients.append(meal.strIngredient13.capitalized)
    }
    
    return ingredients.joined(separator: ", ")
}

struct ContentView: View {
    @StateObject var sheetManager = SheetMananger()
    @State private var meals: [Meal] = []
        
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(meals, id: \.idMeal) { meal in
                    MealItemView(meal: meal)
                        .onTapGesture {
                            fetchMealDetails(for: meal)
                        }
                }
            }
        }
        .onAppear(perform: fetchData)
        .sheet(isPresented: $sheetManager.showSheet) {
            if let meal = sheetManager.selectedMeal {
                MealView(meal: meal)
            }
        }
    }
    
    func fetchData() {
        // Create the URL
        if let url = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert") {
            // Create the URLSession
            let session = URLSession.shared
            
            // Create the data task
            let task = session.dataTask(with: url) { data, response, error in
                // Check for errors
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                // Check if data is available
                if let data = data {
                    // Parse the JSON data
                    do {
                        let response = try JSONDecoder().decode(MealsResponse.self, from: data)
                        
                        // Handle the retrieved data
                        DispatchQueue.main.async {
                            meals = response.meals
                        }
                    } catch {
                        print("Error parsing JSON: \(error)")
                    }
                }
            }
            
            // Start the data task
            task.resume()
        }
    }
    
    func fetchMealDetails(for meal: Meal) {
            if let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=\(meal.idMeal)") {
                let session = URLSession.shared
                let task = session.dataTask(with: url) { data, response, error in
                    if let error = error {
                        print("Error: \(error)")
                        return
                    }
                    
                    if let data = data {
                        do {
                            let response = try JSONDecoder().decode(MealDetailsResponse.self, from: data)
                            if let mealDetails = response.meals.first {
                                DispatchQueue.main.async {
                                    sheetManager.selectedMeal = mealDetails
                                    sheetManager.showSheet = true
                                }
                            }
                        } catch {
                            print("Error parsing JSON: \(error)")
                        }
                    }
                }
                task.resume()
            }
        }
}

struct DropdownSheet: View {
    var meal: Meal
    
    var body: some View {
        VStack {
            Text(meal.strMeal)
                .font(.largeTitle)
                .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
