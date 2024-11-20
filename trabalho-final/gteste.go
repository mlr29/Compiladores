/*Go language*/
package main

import "fmt"
import "asd"

func main() {
    // Testes originais
    var a int;
    var b int;
    b = 10;
    fmt.Println("ola mundo");
    
    // Novos testes
    var x int;
    var i int;
    
    x = 10;
    
    // Teste if
    if x > 5 {
        fmt.Println("x é maior que 5");
    }
    
    // Teste if-else
    if x < 20 {
        fmt.Println("x é menor que 20");
    } else {
        fmt.Println("x é maior ou igual a 20");
    }
    
    // Teste for
    for i := 0; i < 5; i++ {
        fmt.Println("Iteração do loop");
    }
    
    // Testes de erro (comentados)
    // Teste de variável não inicializada
    // fmt.Println(a);  // Deve gerar erro semântico
    
    // Teste de variável não declarada
    // c = 30;  // Deve gerar erro semântico
    
    // Teste de tipo incompatível
    // var y int;
    // y = 3.14;  // Deve gerar erro de tipo
}