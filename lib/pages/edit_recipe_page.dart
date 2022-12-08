import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../providers/category_provider.dart';
import '../providers/ingredient_provider.dart';
import '../providers/my_recipe_provider.dart';

class EditRecipePage extends StatefulWidget {
  final Recipe recipe;
  EditRecipePage({required this.recipe, super.key});

  @override
  State<EditRecipePage> createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  final titleController = TextEditingController();
  final ingredientController = TextEditingController();

  Category? value;

  List<Ingredient> selectedIngredients = [];
  List<Ingredient> preSelectedIngredients = [];

  File? imageFile;

  String? imageError;

  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.recipe.title;
    // ingredientController.text = "1";
    value = context
        .read<CategoryProvider>()
        .categories
        .firstWhere((element) => element.id == widget.recipe.category);

    preSelectedIngredients = context
        .read<IngredientProvider>()
        .ingredients
        .where((element) => element.id == widget.recipe.ingredient)
        .toList();

    // ingredientController.text = widget.recipe.ingredient as String;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Recipe")),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(hintText: "Title"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field is required";
                    }

                    return null;
                  },
                ),
              ),
              // TextFormField(
              //   controller: ingredientController,
              //   decoration: InputDecoration(hintText: "ingredient"),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return "Field is required";
              //     }

              //     if (value.length <= 0) {
              //       return "Description too short";
              //     }

              //     return null;
              //   },
              // ),
              MultiSelectDialogField(
                items: context
                    .watch<IngredientProvider>()
                    .ingredients
                    .map((e) => MultiSelectItem(e, e.title))
                    .toList(),
                initialValue: preSelectedIngredients,
                listType: MultiSelectListType.CHIP,
                onConfirm: (values) {
                  selectedIngredients = values;
                  print(selectedIngredients.map((e) => e.id).join(", "));
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<Category>(
                    isExpanded: true,
                    value: value,
                    items: context
                        .watch<CategoryProvider>()
                        .categories
                        .map(buildMenuItem)
                        .toList(),
                    onChanged: (value) => setState(
                          () {
                            this.value = value;
                          },
                        )),
              ),
              if (imageFile != null)
                Image.file(
                  imageFile!,
                  width: 100,
                  height: 100,
                )
              else
                Image.network(
                  widget.recipe.image,
                  width: 100,
                  height: 100,
                ),
              ElevatedButton(
                  onPressed: () async {
                    var file = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);

                    if (file == null) {
                      print("Use didnt select a file");
                      return;
                    }

                    setState(() {
                      imageFile = File(file.path);
                      imageError = null;
                    });
                  },
                  child: Text("Edit Image")),
              if (imageError != null)
                Text(
                  imageError!,
                  style: TextStyle(color: Colors.red),
                ),
              Spacer(),
              ElevatedButton(
                  onPressed: () async {
                    // form

                    if (imageFile == null) {
                      setState(() {
                        imageError = "Required field";
                      });
                    }

                    if (formKey.currentState!.validate() && imageFile != null) {
                      await context.read<MyRecipeProvider>().editRecipe(
                            id: widget.recipe.id,
                            title: titleController.text,
                            ingredient: ingredientController.text,
                            category: value!.id,
                            image: imageFile!,
                          );

                      context.go('/myrecipe');
                    }
                  },
                  child: Text("Save"))
            ],
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<Category> buildMenuItem(Category item) => DropdownMenuItem(
        value: item,
        child: Text(item.title),
      );
}
