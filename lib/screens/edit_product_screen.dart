import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    description: '',
    id: null,
    imageUrl: '',
    price: 0,
    title: '',
  );
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(
        _updateImageUrl); // Listener needed to react to changes in focus
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // We cannot obtain ModalRoute arguments in initSate, that's why we're doing it here
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct = Provider.of<Products>(context).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          // 'imageUrl': _editedProduct.imageUrl,
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  // We need to dispose our focus nodes, so that no memory leaks will occur
  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      // Making sure not to show a preview if url is invalid.
      if ((!_imageUrlController.text.startsWith('http') &&
          !_imageUrlController.text.startsWith(
              'https')) /*(!_imageUrlController.text.endsWith('.png') && !value.endsWith('.jpg') && !value.endsWith('.jpeg'))*/) {
        return;
      }
      setState(() {}); // This is some kind of hack
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }

    _form.currentState.save();

    setState(() {
      _isLoading = true;
    });

    if (_editedProduct.id != null) {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
          // Await for this result, before we continue to finally, because it returns a future
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred'),
            content: Text('Something went wrong :('),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      } finally {
        // Code which runs, no matter if we succeeded or if we failed.
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.black,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                strokeWidth: 5,
              ),
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        initialValue: _initValues['title'],
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        // onFieldSubmitted gets a value from the TextFormField, we instead use '_', to tell it we don't need it
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            title: value,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                          );
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please, provide a Title.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['price'],
                        decoration: InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: double.parse(value),
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                          );
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please, provide a price.';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please, provide a valid number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Must provide a positive number or higher than 0.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['description'],
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        onSaved: (value) {
                          _editedProduct = Product(
                            title: _editedProduct.title,
                            description: value,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                          );
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please, provide a description.';
                          }
                          if (value.length < 10) {
                            return 'Should be at least 10 characters long';
                          }
                          return null;
                        },
                      ),
                      Row(
                        // Row has unconstrained width, takes TextFormField boundaries, TextFormField takes infinite width
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? Text('Enter a URL')
                                : FittedBox(
                                    child:
                                        Image.network(_imageUrlController.text),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              // initialValue: _initValues['imageUrl'],
                              // We cannot handle both, the initialValue and the controller.
                              decoration:
                                  InputDecoration(labelText: 'Image URL'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              onSaved: (value) {
                                _editedProduct = Product(
                                  title: _editedProduct.title,
                                  description: _editedProduct.description,
                                  price: _editedProduct.price,
                                  imageUrl: value,
                                  id: _editedProduct.id,
                                  isFavorite: _editedProduct.isFavorite,
                                );
                              },
                              validator: (value) {
                                const regExWithHttpProtocol =
                                    'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)';
                                const regExWithoutHttpProtocol =
                                    '[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)';
                                if (value.isEmpty) {
                                  return 'Please provide an image URL.';
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  // Si no inicia con http ni con https, entra a la condición, me manda error.
                                  return 'Invalid URL, Please enter a valid one';
                                }
                                // if(!value.endsWith('.png') && !value.endsWith('.jpg') && !value.endsWith('.jpeg')) {
                                //   return 'URL does not contain a valid image';
                                // }

                                // if (!value.contains(
                                //         new RegExp(regExWithHttpProtocol)) &&
                                //     !value.contains(
                                //         new RegExp(regExWithoutHttpProtocol))) {
                                //   return 'Invalid URL, Please enter a valid one';
                                // }
                                return null;
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                //   child: ListView(
                //     children: <Widget>[
                //       TextFormField(
                //         decoration: InputDecoration(labelText: 'Title'),
                //         textInputAction: TextInputAction.next,
                //       ),
                //     ],
                //   ),
                // ),
              ),
            ),
    );
  }
}
