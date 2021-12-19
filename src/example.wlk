/** First Wollok example 
Nombre y Apellido: Ramon Angel Vega Baldiviezo
Legajo: 1492019

Enunciado: https://docs.google.com/document/d/1rklv10IKyrHQolzxdhA_aBOT9mkEVkVxRfolJdcgdU0/edit# 
*/


/* SE PIDE:

* A) familia.durmiendoConLosPeces(mafioso)
* 
* B) familia.elMasPeligroso()
* 
* C) mafioso.ataqueSorpresa(familia)
* 
* D) familia.luto()
* 
* E) Modelar un revolver Oxidado. Hereda de un revolver 
*    y sobreescribe	
*/

class ArmaException inherits Exception { }
class MafiosoException inherits Exception { }

class Familia{
	const miembros = #{}

	method durmiendoConLosPeces(mafioso) = mafioso.estaVivo()

	method elMasPeligroso() = miembros.max{ mafioso => mafioso.nivelDeIntimidacion()}

	method elDon() = miembros.filter({ mafioso => mafioso.rango() == don}).head()

	method  soldadosConMasDeDosArmasEnCondiciones() = miembros.filter{ 
		mafioso => mafioso.rango() == soldado && mafioso.cantidadDeArmasEnCondiciones()>2}

	method  subjefesQueNoTienenMaDeDosArmasEnCondiciones() =  miembros.filter{ 
		mafioso => mafioso.rango() == subjefe && mafioso.cantidadDeArmasEnCondiciones()<2}

	method recategorizarMiembros(){
		self.soldadosConMasDeDosArmasEnCondiciones().forEach{mafioso => mafioso.rango(subjefe)}
		self.subjefesQueNoTienenMaDeDosArmasEnCondiciones().forEach{mafioso => mafioso.rango(soldado)}
	}
	
	method miembrosVivos() = miembros.filter{ mafioso => self.durmiendoConLosPeces(mafioso)}

	method reacondicionarArmas(){
		self.miembrosVivos().forEach{ mafioso => mafioso.reacondicionarArmas()}
	}

	method nombrarNuevoDon(){
		const mafioso = self.elMasPeligroso()
		mafioso.rango(don)
	}

	method luto(){
		if(self.durmiendoConLosPeces(self.elDon())){
			throw new MafiosoException(message = "No esta Muerto por lo que no debe haber Luto") 	
		}
		else{
			self.recategorizarMiembros()
			self.reacondicionarArmas()
			self.nombrarNuevoDon()
		}
	}
}

class Mafioso{
	var property estaVivo = true
	var property cantidadDeHeridas = 0
	var property rango // don || subjefe || soldado
	const armas = [] // revolver || daga || cuerdaDePiano

	method morir(){ estaVivo = false}
	method herir() = if(cantidadDeHeridas<3) cantidadDeHeridas += 1 else self.morir() 
	method ataqueSorpresa(familia){
		const victima = familia.elMasPeligroso()
		rango.hacerSuTrabajo(self,victima)
	}

	method nivelDeIntimidacion(){ 
		const subtotal = armas.sum{ arma => arma.peligrosidad()}
		return rango.intimidacion(subtotal)
	}

	method desarmar(){ armas.clear()}
	method cantidadDeArmasEnCondiciones() = armas.filter({ arma => arma.estaEnCondiciones()}).size() 
	method primerArmaEnCondiciones()= armas.filter({ arma => arma.estaEnCondiciones()}).head()
	method primerArma(){
		if(armas.isEmpty()){
			throw new ArmaException(message = "No tiene Armas") 
		}else{
			return armas.head()
		}
	} 	

	method reacondicionarArmas(){
		armas.forEach{ arma => arma.estaEnCondiciones(true)}
		armas.add(new Revolver(peligrosidadBase = 10))
	} 
}

// Armas
class Arma{
	var property peligrosidadBase
	var property estaEnCondiciones = true

	method usar(victima){}
	method peligrosidad() = if (!estaEnCondiciones) 1 else self.peligrosidadBase()
}

class Revolver inherits Arma{
	var cantidadDeBalas = 6
 
	override method estaEnCondiciones() = cantidadDeBalas>0 
	override method usar(victima){
		if( self.estaEnCondiciones()){
			victima.morir()
			cantidadDeBalas -= 1	
		} 
	}
	method recargar(){ cantidadDeBalas = 6}

	override method peligrosidadBase() = 2*cantidadDeBalas
}

class Daga inherits Arma{
	override method usar(victima){victima.herir()}
}

class CuerdaDePiano inherits Arma{

	override method usar(victima){ 
		if( self.estaEnCondiciones()) victima.morir() else victima.herir()
	} 

	override method peligrosidadBase() = 5	
}

// Rangos
object don{
	method hacerSuTrabajo(mafioso,victima){ mafioso.desarmar(victima)}
	method intimidacion(subtotal) = subtotal + 20
}

object subjefe{
	method hacerSuTrabajo(mafioso,victima){
		if(mafioso.cantidadDeArmasEnCondiciones()!=0){
			mafioso.primerArmaEnCondiciones().usar(victima)
		}else{
			mafioso.primerArma().usar(victima)
		}
	}
	method intimidacion(subtotal) = 2*subtotal
}

object soldado{
	method hacerSuTrabajo(mafioso,victima){ mafioso.primerArma().usar(victima)}
	method intimidacion(subtotal) = subtotal 
}


//punto E
class RevolverOxidado inherits Revolver{
 	var balaRamdom = 1
 	
	method disparoRamdom(){		
		if(cantidadDeBalas == 6){balaRamdom = 3.randomUpTo(6).roundUp()} //número random entre 4 y 6
		if(cantidadDeBalas == 3){balaRamdom = 0.randomUpTo(3).roundUp()} //número random entre 1 y 3
	}
	
	override method usar(victima){

		if( self.estaEnCondiciones()){
			self.disparoRamdom()
			if(cantidadDeBalas==balaRamdom) victima.herir() else victima.morir()	
			cantidadDeBalas -= 1	
		} 
	}

	override method peligrosidadBase() = super()/2
}