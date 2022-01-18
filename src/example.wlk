/*
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

//############## Familia
class Familia{
	const miembros = #{}

	method elMasPeligroso() = self.miembrosVivos().max{ mafioso => mafioso.nivelDeIntimidacion()}

	method miembrosVivos() = miembros.filter{ mafioso => mafioso.estaVivo()}

	method elDon() = self.miembrosVivos().find{ mafioso => mafioso.rango() == don}
	method elDonEstaVivo() = self.miembrosVivos().any{mafioso => mafioso.rango() == don}

	method recategorizables(condicionDelRango) = self.miembrosVivos().filter(condicionDelRango)

	method recategorizar(condicionDelRango, categoria){
		self.recategorizables(condicionDelRango).forEach{mafioso => mafioso.rango(categoria)} 
	}

	method recategorizarMiembros(){
		// Recaterizar Soldados, los que cumplan la condicion pasan a Subjefes
		self.recategorizar({ 
		mafioso => mafioso.rango() == soldado && mafioso.cantidadDeArmasEnCondiciones()>2
		}, subjefe)
		// Recategorizar Subjefes, los que cumpla la condicion pasan a Soldados
		self.recategorizar({ 
		mafioso => mafioso.rango() == subjefe && mafioso.cantidadDeArmasEnCondiciones()<2
		}, soldado)
	}
	
	method acondicionarArmas(){
		self.miembrosVivos().forEach{ mafioso => 
			mafioso.acondicionarArmas() 
			mafioso.armar(new Revolver(peligrosidadBase = 10))
		}
	}

	method nombrarNuevoDon(){
		const mafiosoMasPeligroso = self.elMasPeligroso()
		mafiosoMasPeligroso.rango(don)
	}

	method luto(){
		if(self.elDonEstaVivo()){
			throw new MafiosoException(message = "El Don esta vivo por lo que no debe haber Luto") 	
		}
		else{ 
			self.recategorizarMiembros()
			self.acondicionarArmas()
			self.nombrarNuevoDon()
		}
	}
}


//############## Mafioso 
class Mafioso{
	const property nombre
	var estaVivo = true //No debe tener un setter xq no puede ser revivido.
	var cantidadDeHeridas = 0 //No debe tener un setter xq no puede ser herido en mas de una unidad a la vez.
	var property rango // don || subjefe || soldado
	const property armas = [] // Revolver || Daga || CuerdaDePiano || RevolverOxidado

	method estaVivo() = estaVivo
	
	method cantidadDeHeridas() = cantidadDeHeridas 
	
	method morir(){ estaVivo = false}
	
	method herir() { 
		if(cantidadDeHeridas<3) cantidadDeHeridas += 1 
		else{
			if(cantidadDeHeridas==3) cantidadDeHeridas += 1
			self.morir()
		} 
	} 
	
	method hacerSuTrabajo(victima){
		rango.hacerSuTrabajo(self,victima)
	}
	
	method ataqueSorpresa(familia){
		const victima = familia.elMasPeligroso()
		self.hacerSuTrabajo(victima)
	}

	method nivelDeIntimidacion(){ 
		const subtotal = armas.sum{ arma => arma.peligrosidad()}
		return rango.intimidacion(subtotal)
	}

	method desarmar(){ armas.clear()}
	
	method cantidadDeArmasEnCondiciones() = armas.count{ arma => arma.estaEnCondiciones()}
	
	method primerArmaEnCondiciones()= armas.find{ arma => arma.estaEnCondiciones()}
	
	method primerArma(){
		if(armas.isEmpty()){
			throw new ArmaException(message = "No tiene Armas para atacar a la victima") 
		}else{
			return armas.head()
		}
	} 	
	
	method armar(arma){armas.add(arma)}
	
	method acondicionarArmas(){ armas.forEach{ arma => arma.acondicionar()} } 
}

//############# Armas
class Arma{
	var property peligrosidadBase = 1
	
	method estaEnCondiciones() = true
	method acondicionar(){}
	method usar(victima){}
	method peligrosidad() = if (!self.estaEnCondiciones()) 1 else self.peligrosidadBase()
}

class Revolver inherits Arma{
	var cantidadDeBalas = 6 //No debe tener un setter xq no puede tener mas de seis balas.
 	
 	method cantidadDeBalas() = cantidadDeBalas
	override method estaEnCondiciones() = cantidadDeBalas>0
	override method acondicionar(){ self.recargar()} 
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
	var property estaTensa = true
	
	override method estaEnCondiciones() = self.estaTensa()
	override method acondicionar(){ estaTensa = true} 
	override method usar(victima){ 
		if( self.estaEnCondiciones()) victima.morir() else victima.herir()
	} 

	override method peligrosidadBase() = 5	
}

class RevolverOxidado inherits Revolver{// punto E
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

class Revolver_Oxidado inherits Revolver{// punto E: Planteo propuesto por otros compañeros
 	
	override method usar(victima){
		if( self.estaEnCondiciones()){
			if(0.randomUpTo(3).roundUp()==1){
				victima.herir()
			}else{
				victima.morir()
			}	
			cantidadDeBalas -= 1	
		} 
	}    

	override method peligrosidadBase() = super()/2
}

//#############  Rangos
object don{
	method hacerSuTrabajo(mafioso,victima){ victima.desarmar()}
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
