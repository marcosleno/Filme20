//
//  main.swift
//  Filme13
//
//  Created by Marcos on 29/12/23.
//

import Foundation
import SwiftKuery

let utils = CommonUtils.sharedInstance

/*
//1 - instanciando a tabela Filmes
let filmes = Filmes()
utils.criaTabela (filmes)
print("Tabela Filme Criada")

//2- instanciando a tabela Elencos
let elencos = Elencos()
_ = elencos.foreignKey(elencos.idfilme, references: filmes.idFilme)
utils.criaTabela (elencos)
print("Tabela Elenco Criada")
*/


/*
//3 - Inserindo Filmes no banco de dados
let listaFilmes = [
    Filme (idFilme: 1, titulo: "Filme A", genero: "Herois", origem: "EUA", duracao: 2, ano:2023, capa: "image.jpg", trailer: "video.mp4"),
    Filme (idFilme: 2, titulo: "Filme B", genero: "Herois", origem: "EUA", duracao: 2, ano: 2023, capa: "image.jpg", trailer: "video.mp4"),
    Filme (idFilme: 3, titulo: "Filme C", genero: "Herois", origem: "EUA", duracao: 2, ano: 2023, capa: "image.jpg", trailer: "video.mp4")
]


utils.executaQuery (Insert(into: Filmes (), rows: listaFilmes.map {$0.colunas}))
print("Os registros de Filmes foram inseridos")

//4 - Inserindo Elenco no banco de dados
let listaElenco = [
    Elenco (idElenco: 1, ator: "Felipe", idade: 25, nacionalidade: "Brasileiro", filme:listaFilmes[0]),
    Elenco (idElenco: 2, ator: "Ana", idade: 25, nacionalidade: "Brasileiro", filme:listaFilmes [1]),
    Elenco (idElenco: 3, ator: "Maria", idade: 25, nacionalidade: "Brasileiro", filme:listaFilmes [2]),
    Elenco (idElenco: 4, ator: "Robert", idade: 25, nacionalidade: "Brasileiro", filme:listaFilmes [0])
]

utils.executaQuery (Insert(into: Elencos (), rows: listaElenco.map {$0.colunas}))
print("Os registros de Elencos foram inseridos")
*/





let elencos = Elencos()
let filmes = Filmes()
/*
//5-atualiza o banco de dados, alterando o registro da tabela elenco com idElenco = 1, para ator = "Felipe santos" e idade = 29
utils.executaQuery(Update(elencos, set: [(elencos.ator, "Felipe Santos"), (elencos.idade, 29)],where: elencos.idElenco == 1))
print("Alterado o nome e idade do Felipe")
*/

/*
//6 - realiza a exclusao do registro da tabela elenco com idElenco == 4
utils.executaQuery(Delete(from:elencos).where(elencos.idElenco == 4))
print("Ator excluido do banco - Robert")
 */


//7 - realiza uma consulta unindo as tabelas Elencos e Filmes
func consulta(_ select: Select){
    let utils = CommonUtils.sharedInstance
    utils.executaSelect(select){
        registros in
        guard let registros = registros else{
            return print("Sem registros")
        }
        registros.forEach{
            linha in
            linha.forEach{
                item in
                print("\(item ?? "")".fill(), terminator: " ")
            }
            print()
        }
    }
}

//8 - extensao de string chamada de fill que formata a string, para alinhamento da visualizao de dados
public extension String{
func fill(to: Int = 20) -> String{
    var saida = self
    if self.count < to {
        for _ in 0..<(to - self.count){
            saida += " "
        }
    }
    return saida
    }
}

//9-realiza uma consulta no banco de dados
consulta (Select(elencos.ator, filmes.titulo, filmes.ano, from:elencos).join(filmes).on(elencos.idfilme == filmes.idFilme))

/*
// 10 - Excluindo as tabelas do banco de dados
utils.removeTabela(elencos)
utils.removeTabela(filmes)
*/
