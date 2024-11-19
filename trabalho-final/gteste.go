/*Go language*/
package main

import "fmt"

func main() {
    // Teste de declarações e inicializações
    var a int;
    var b int;
    var c int;
    
    // Teste de atribuições
    a = 10;
    // b = 20;
    
    // Teste de variável não inicializada (deve gerar erro semântico)
    // fmt.Println(c);  // Descomente para testar erro
    
    // Teste de variável não declarada (deve gerar erro semântico)
    // d = 30;  // Descomente para testar erro
    
    // Teste de tipo incompatível (deve gerar erro de tipo)
    var x int;
    x = 3.14;  // Descomente para testar erro de tipo
    
    // Teste de if (implementação futura)

    // if a > b {
    //     fmt.Println("a é maior que b");
    // }
    
    // Teste de for (implementação futura)
    // for i := 0; i < 5; i++ {
    //     fmt.Println(i);
    // }
    
    // Teste de cast (implementação futura)
    // var f float64;
    // f = float64(a);

    b = 20 + 3.14;  // Deve gerar erro: tipos incompatíveis em soma
   
    fmt.Println("Teste do compilador");
}