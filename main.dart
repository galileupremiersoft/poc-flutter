import 'dart:convert';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // JSON de exemplo com regex devidamente escapadas
  final String jsonData = '''
{
  "type": "form",
  "title": "Formulário Completo de Exemplo",
  "name": "formulario_completo",
  "children": [
    {
      "type": "page",
      "title": "Página 1 - Dados Pessoais e Contato",
      "name": "pagina1",
      "children": [
        {
          "type": "section",
          "title": "Seção de Dados Pessoais",
          "name": "dados_pessoais",
          "children": [
            {
              "type": "input",
              "title": "Nome Completo",
              "name": "nome_completo",
              "inputType": "text",
              "required": true,
              "defaultValue": "",
              "validators": {
                "regex": "^[A-Za-zÀ-ÿ\\\\s]+\$"
              }
            },
            {
              "type": "input",
              "title": "Idade",
              "name": "idade",
              "inputType": "number",
              "required": true,
              "defaultValue": 0,
              "validators": {
                "min": 0,
                "max": 150
              }
            },
            {
              "type": "input",
              "title": "Data de Nascimento",
              "name": "data_nascimento",
              "inputType": "date",
              "required": true,
              "defaultValue": "",
              "validators": {
                "regex": "^\\\\d{4}-\\\\d{2}-\\\\d{2}\$"
              }
            }
          ]
        },
        {
          "type": "section",
          "title": "Seção de Contato",
          "name": "contato",
          "children": [
            {
              "type": "input",
              "title": "Email",
              "name": "email",
              "inputType": "text",
              "required": true,
              "defaultValue": "",
              "validators": {
                "regex": "^[\\\\w-\\\\.]+@([\\\\w-]+\\\\.)+[\\\\w-]{2,4}\$"
              }
            },
            {
              "type": "input",
              "title": "Preferência de Contato",
              "name": "preferencia_contato",
              "inputType": "select",
              "required": true,
              "defaultValue": "email",
              "options": [
                { "label": "Email", "value": "email" },
                { "label": "Telefone", "value": "telefone" }
              ]
            },
            {
              "type": "input",
              "title": "Telefone",
              "name": "telefone",
              "inputType": "text",
              "required": false,
              "defaultValue": "",
              "validators": {
                "regex": "^\\\\+?[0-9]{10,15}\$"
              },
              "visibilityConditions": {
                "dependsOn": "preferencia_contato",
                "value": "telefone"
              }
            },
            {
              "type": "input",
              "title": "Aceito Receber Newsletter",
              "name": "newsletter",
              "inputType": "checkbox",
              "required": false,
              "defaultValue": false
            }
          ]
        }
      ]
    },
    {
      "type": "page",
      "title": "Página 2 - Endereço",
      "name": "pagina2",
      "children": [
        {
          "type": "section",
          "title": "Seção de Endereço",
          "name": "endereco",
          "children": [
            {
              "type": "input",
              "title": "Rua",
              "name": "rua",
              "inputType": "text",
              "required": true,
              "defaultValue": ""
            },
            {
              "type": "input",
              "title": "Número",
              "name": "numero",
              "inputType": "number",
              "required": true,
              "defaultValue": 0,
              "validators": {
                "min": 0
              }
            },
            {
              "type": "input",
              "title": "Complemento",
              "name": "complemento",
              "inputType": "text",
              "required": false,
              "defaultValue": ""
            },
            {
              "type": "input",
              "title": "CEP",
              "name": "cep",
              "inputType": "text",
              "required": true,
              "defaultValue": "",
              "validators": {
                "regex": "^[0-9]{5}-[0-9]{3}\$"
              }
            }
          ]
        }
      ]
    }
  ]
}
  ''';

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> formDefinition = json.decode(jsonData);
    return MaterialApp(
      title: formDefinition['title'] ?? 'Dynamic Form',
      home: Scaffold(
        appBar: AppBar(
          title: Text(formDefinition['title'] ?? 'Dynamic Form'),
        ),
        body: FormWidget(formDefinition: formDefinition),
      ),
    );
  }
}

class FormWidget extends StatefulWidget {
  final Map<String, dynamic> formDefinition;

  const FormWidget({Key? key, required this.formDefinition}) : super(key: key);

  @override
  _FormWidgetState createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {};
  int currentPageIndex = 0;
  late List<dynamic> pages;

  @override
  void initState() {
    super.initState();
    // Filtra as páginas do formulário
    pages = widget.formDefinition['children']
        .where((child) => child['type'] == 'page')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: buildWidget(pages[currentPageIndex]),
            ),
          ),
        ),
        buildNavigationButtons()
      ],
    );
  }

  // Botões de navegação para mudar de página
  Widget buildNavigationButtons() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentPageIndex > 0)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentPageIndex--;
                });
              },
              child: const Text('Página Anterior'),
            )
          else
            const SizedBox(width: 120), // Espaço reservado quando não há botão anterior
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                // Se estiver na última página, finaliza o formulário
                if (currentPageIndex == pages.length - 1) {
                  // Processar os dados do formulário
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Formulário Enviado'))
                  );
                } else {
                  setState(() {
                    currentPageIndex++;
                  });
                }
              }
            },
            child: Text(
              currentPageIndex == pages.length - 1
                  ? 'Finalizar'
                  : 'Próxima Página'
            ),
          ),
        ],
      ),
    );
  }

  // Função recursiva que constrói widgets a partir do JSON
  Widget buildWidget(Map<String, dynamic> node) {
    // Se o nó possuir condições de visibilidade, verifica antes de renderizar
    if (node.containsKey('visibilityConditions')) {
      String dependsOn = node['visibilityConditions']['dependsOn'];
      var expectedValue = node['visibilityConditions']['value'];
      if (formData[dependsOn] != expectedValue) {
        return const SizedBox.shrink();
      }
    }

    String type = node['type'];
    switch (type) {
      case 'form':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: (node['children'] as List)
              .map<Widget>((child) => buildWidget(child))
              .toList(),
        );
      case 'page':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              node['title'] ?? '',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 10),
            ...((node['children'] as List)
                .map<Widget>((child) => buildWidget(child))
                .toList())
          ],
        );
      case 'section':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                node['title'] ?? '',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              const SizedBox(height: 8),
              ...((node['children'] as List)
                  .map<Widget>((child) => buildWidget(child))
                  .toList())
            ],
          ),
        );
      case 'input':
        return buildInput(node);
      default:
        return const SizedBox.shrink();
    }
  }

  // Constrói o campo de input com base no tipo e implementa validação e lógica de visibilidade
  Widget buildInput(Map<String, dynamic> node) {
    // Verifica condições de visibilidade específicas para inputs
    if (node.containsKey('visibilityConditions')) {
      String dependsOn = node['visibilityConditions']['dependsOn'];
      var expectedValue = node['visibilityConditions']['value'];
      if (formData[dependsOn] != expectedValue) {
        return const SizedBox.shrink();
      }
    }

    String inputType = node['inputType'];
    String name = node['name'];
    String title = node['title'];
    bool requiredField = node['required'] ?? false;
    var defaultValue = node['defaultValue'];

    switch (inputType) {
      case 'text':
      case 'date':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            initialValue: defaultValue?.toString() ?? '',
            decoration: InputDecoration(labelText: title),
            validator: (value) {
              if (requiredField && (value == null || value.isEmpty)) {
                return '$title é obrigatório';
              }
              if (node.containsKey('validators') &&
                  node['validators']['regex'] != null &&
                  value != null &&
                  value.isNotEmpty) {
                RegExp regex = RegExp(node['validators']['regex']);
                if (!regex.hasMatch(value)) {
                  return 'Formato inválido para $title';
                }
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                formData[name] = value;
              });
            },
            onSaved: (value) {
              formData[name] = value;
            },
          ),
        );
      case 'number':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            initialValue: defaultValue?.toString() ?? '',
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: title),
            validator: (value) {
              if (requiredField && (value == null || value.isEmpty)) {
                return '$title é obrigatório';
              }
              if (value != null && value.isNotEmpty) {
                double? number = double.tryParse(value);
                if (number == null) {
                  return '$title deve ser um número';
                }
                if (node.containsKey('validators')) {
                  if (node['validators']['min'] != null &&
                      number < node['validators']['min']) {
                    return '$title deve ser no mínimo ${node['validators']['min']}';
                  }
                  if (node['validators']['max'] != null &&
                      number > node['validators']['max']) {
                    return '$title deve ser no máximo ${node['validators']['max']}';
                  }
                }
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                formData[name] = double.tryParse(value);
              });
            },
            onSaved: (value) {
              formData[name] =
                  value != null ? double.tryParse(value) : null;
            },
          ),
        );
      case 'select':
        List options = node['options'] ?? [];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DropdownButtonFormField(
            value: formData[name] ?? defaultValue,
            decoration: InputDecoration(labelText: title),
            items: options.map<DropdownMenuItem>((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                formData[name] = value;
              });
            },
            validator: (value) {
              if (requiredField && value == null) {
                return '$title é obrigatório';
              }
              return null;
            },
            onSaved: (value) {
              formData[name] = value;
            },
          ),
        );
      case 'checkbox':
        bool currentValue = formData[name] ?? defaultValue ?? false;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: CheckboxListTile(
            title: Text(title),
            value: currentValue,
            onChanged: (bool? value) {
              setState(() {
                formData[name] = value;
              });
            },
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

