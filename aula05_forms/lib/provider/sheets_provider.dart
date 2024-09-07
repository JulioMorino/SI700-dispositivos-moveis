import 'dart:convert'; // Biblioteca para manipulação de JSON.
import 'dart:developer'; // Biblioteca para logs de depuração.
import 'package:googleapis/sheets/v4.dart'
    as sheets; // Biblioteca para interagir com Google Sheets.
import 'package:googleapis/drive/v3.dart'
    as drive; // Biblioteca para interagir com Google Drive.
import 'package:googleapis_auth/auth_io.dart'
    as auth; // Biblioteca para autenticação com APIs do Google.
import 'package:dio/dio.dart'; // Biblioteca para fazer requisições HTTP.
import 'package:flutter/services.dart'
    show rootBundle; // Biblioteca para carregar assets.

class SheetsDatabase {
  // Instância singleton da classe SheetsDatabase
  static SheetsDatabase helper = SheetsDatabase._createInstance();

  // ID da planilha e nome da aba
  final _spreadsheetId =
      "1WdtDDPIHO7bRIlhKi0UnfLIPq-8UDQtU-Pj-S9TmRSM"; // Substitua pelo seu ID da planilha
  final _sheetName =
      'Dados_salvos_atividade2'; // Substitua pelo nome da aba da planilha

  // Construtor privado para a instância singleton
  SheetsDatabase._createInstance();

  // Método para obter o cliente autenticado com as credenciais do Google.
  Future<auth.AuthClient> getAuthClient() async {
    // Carrega o arquivo de credenciais JSON.
    var credentialsJson =
        await rootBundle.loadString('assets/credentials.json');
    // Cria as credenciais de conta de serviço a partir do JSON.
    var credentials =
        auth.ServiceAccountCredentials.fromJson(json.decode(credentialsJson));
    // Define os escopos de acesso necessários para Sheets e Drive.
    final scopes = [
      sheets.SheetsApi.spreadsheetsScope,
      drive.DriveApi.driveScope
    ];
    // Retorna um cliente autenticado com os escopos necessários.
    return await auth.clientViaServiceAccount(credentials, scopes);
  }

  // Método para submeter dados para o Google Sheets.
  Future<String?> submitData(List<String> parsedResponse) async {
    // Obtém o cliente autenticado.
    var client = await getAuthClient();
    try {
      var dio = Dio(); // Cria uma instância do Dio para requisições HTTP.

      // Verifica o número de colunas para garantir que não exceda o limite.
      if (parsedResponse.length > 18277) {
        log('Too many columns generated from the CSV string.'); // Log de erro.
        return "Código Incorreto - Número de campos diferentes do esperado."; // Mensagem de erro.
      }

      // Obtém o token de acesso para autenticação na API.
      var accessToken = client.credentials.accessToken;
      var headers = {
        'Authorization':
            '${accessToken.type} ${accessToken.data}', // Adiciona o token no cabeçalho da requisição.
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      // Define o intervalo de inserção. Neste caso, insere sempre na coluna A.
      var insertRange = '$_sheetName!A:A';
      // Prepara o corpo da requisição com os dados a serem inseridos.
      var requestBody = {
        'values': [parsedResponse]
      };
      log('Request Body for Insert: $requestBody'); // Log do corpo da requisição.
      // Faz a requisição para inserir os dados no Google Sheets.
      var responseResult = await dio.post(
        'https://sheets.googleapis.com/v4/spreadsheets/$_spreadsheetId/values/$insertRange:append?valueInputOption=RAW',
        options: Options(
          headers: headers,
        ),
        data: jsonEncode(requestBody),
      );

      log('Response from API: ${responseResult.data}'); // Log da resposta da API.
      log('Data submitted successfully'); // Log de sucesso.
      return "success"; // Retorna sucesso.
    } catch (e) {
      log('Error submitting data: $e'); // Log de erro.

      return "Erro ao submeter os dados: $e"; // Retorna uma mensagem de erro geral.
    }
  }
}
