//
//  Utils.swift
//  Filme13
//
//  Created by Marcos on 29/12/23.
//

import Foundation
import SwiftKuery
import SwiftKueryMySQL

class CommonUtils {
    private var pool: ConnectionPool?
    private var connection: Connection?
    static let sharedInstance = CommonUtils()
    private init(){}
    //1 - Pool de conexao com o banco de dados, lendo as configuracoes de conexao de um arquivo json(connection.json)
    private func getConnectionPool(characterSet: String? = nil) -> ConnectionPool{
        if let pool = pool {
            return pool
        }
        do{
            let connectionFile = #file.replacingOccurrences(of: "Utils.swift", with:"connection.json")
            let data = Data (referencing: try NSData(contentsOfFile: connectionFile))
            let json = try JSONSerialization.jsonObject(with: data)
            if let dictionary = json as? [String: String]{
                let host = dictionary["host"]
                let username = dictionary["username"]
                let password = dictionary["password"]
                let database = dictionary["database"]
                let port: Int? = nil
                if let portString = dictionary["port"]{
                    //port = Int(portString)
                }
                let randomBinary = arc4random_uniform (2)
                let poolOptions = ConnectionPoolOptions(initialCapacity:1, maxCapacity: 1)
                if characterSet != nil || randomBinary == 0{
                    pool = MySQLConnection.createPool (host: host,user: username, password:password, database: database, port: port, characterSet: characterSet, connectionTimeout: 10000, poolOptions: poolOptions)
                }else{
                    //"mysql://username: password@host:port/datadase"
                    var urlString = "mysql://"
                    if let username = username, let password = password{urlString += "\(username):\(password)@"
                    }
                    
                    urlString += host ?? "localhost"
                    
                    if let port = port{
                        urlString += ":\(port)"
                    }
                    if let database = database{
                        urlString += "/\(database)"
                    }
                    if let url = URL(string: urlString){
                        pool = MySQLConnection.createPool(url: url, poolOptions: poolOptions)
                    }else{
                        pool = nil
                        print("URL tem o formato invalido: \(urlString)")
                    }
                }
            }else{
                pool = nil
                print("""
                      Formato invalido no connection.json: \(json)
                      """)
                }
            }catch{
                print("Erro lancado")
                pool = nil
            }
            return pool!
        }


        //2-realiza conexao com o banco de dados
        func getConnection() -> Connection?{
            if let connection = connection{
                return connection
            }
            self.connection = nil
            getConnectionPool().getConnection{connection, error in
                        guard let connection = connection else{
                            guard let error = error else {
                                return print("Erro ao conectar no banco: \(error?.localizedDescription ?? "Erro desconhecido")")
                            }
                        return print("Erro ao conectar no banco:\(error.localizedDescription)")
                        }
                self.connection = connection
                return
            }
            return connection
        }
        //3-cria as tabelas no banco de dados
        func criaTabela (_ tabela: Table){
            let thread = DispatchGroup()
            thread.enter()
            
            guard let con = getConnection() else {
                return print("Sem conexao")
            }
            tabela.create(connection: con){
                result in
                if result.success{
                    print("Falha ao criar a tabela\(tabela.nameInQuery)")
                }
                thread.leave()
            }
            thread.wait()
            }


        //4 - esta funcao executa uma query no banco de dados e retorna imprime mensagens de erro caso encontre.
        func executaQuery(_ query: Query) {
            let thread = DispatchGroup()
            thread.enter()
            if let connection = getConnection(){
                connection.execute(query: query) {
                    result in
                    var nomeQuery = String(describing: type(of:query))
                    if nomeQuery == "Raw" {
                        nomeQuery = String(describing:query.self).split(separator: "\"")[1].split(separator: "")[0].capitalized
                    }
            if let erro = result.asError{
                print("\(nomeQuery), Falha de execucao:\(erro)")
            }
            thread.leave()
        }
    }else{
        print("Sem conexao")
        thread.leave()
        }
        thread.wait()
    }
//continua

        //5 - esta funcao executa uma query de selecao no banco de dados e retorna os resultados.
        func executaSelect(_ query: Select, aoFinal: @escaping ([[Any?]]?) ->()) {
            let thread = DispatchGroup()
            thread.enter()
            var registros = [[Any?]]()
            if let connection = getConnection(){
                connection.execute(query: query){
                    result in
                    guard let dados = result.asResultSet else{
                        print ("Não houve resultado da consulta")
                               return thread.leave()
                    }
                    dados.forEach{ linha, error in
                        if let _linha = linha{
                            var colunas: [Any?] = [Any?]()
                            _linha.forEach({ atributo in
                                colunas.append(atributo)
                            })
                            registros.append(colunas)
                        }else{
                            thread.leave()
                        }
                    }
                }
            }else{
                print("Sem Conexao")
                thread.leave()
            }
            thread.wait()
            aoFinal(registros)
        }
        //5-esta funcao remove tabelas do banco de dados
        func removeTabela (_ tabela: Table){
            executaQuery(tabela.drop())
        }
}
