use db_empresa
go

-- Login
create or alter proc loginUsuario(@correo varchar(100), @clave varchar(100))
as
	begin
		if not exists(select * from [Accounts].Customer where user_email = @correo and user_password = @clave)
			begin
				if not exists(select * from [Accounts].Profesional where user_email = @correo and user_password = @clave)
					begin
						if not exists(select * from [Accounts].Company where company_email = @correo and company_password = @clave)
							begin
								return null
							end
						else
							select * from [Accounts].Company where company_email = @correo and company_password = @clave
					end
				else
					select * from [Accounts].Profesional where user_email = @correo and user_password = @clave
			end
		else
			select * from [Accounts].Customer where user_email = @correo and user_password = @clave
	end
go

----------------------------------------
------------- Api/Customer -------------
----------------------------------------

-- Create
create or alter proc insertarCliente
(@nombre varchar(30), @apellido varchar(30), @correo varchar(50), @clave varchar(50))
as
	begin
		insert into [Accounts].[Customer]([rol_id], [user_name], [user_lastname],[user_email],[user_password]) values
		(default, @nombre, @apellido, @correo, @clave)
	end
go

-- Get
create or alter proc seleccionarClientes 
as
	begin
		select * from [Accounts].[Customer]
	end
go

-- Get{id}
create or alter proc seleccionarCliente(@id int)
as
	begin
		select * from [Accounts].[Customer] where [user_id] = @id
	end
go

-- Delete{id}
create or alter proc eliminarCliente(@id int)
as
	begin
		if exists(select * from [Accounts].[Customer] where [user_id] = @id)
			delete from  [Accounts].[Customer] where [user_id] = @id

		else
			print 'El cliente que quieres eliminar no existe'
	end
go

---------------------------------------
------------- Api/Company -------------
---------------------------------------

-- Create
create or alter proc crearEmpresa(@empresa varchar(20), @edad varchar(10), @correoEmpresa varchar(50), @claveEmpresa varchar(50), @correoPaypal varchar(50), @correoFono varchar(50))
as
	begin
		insert into [Accounts].[Company]([rol_id], [company_name], [company_age],[company_email], [company_password], [company_paypal_email], [company_phone])
		values(default, @empresa, @edad, @correoEmpresa, @claveEmpresa, @correoPaypal, @correoFono)
	end
go

-- Edit
create or alter proc editarEmpresa(@id varchar(2), @nombre varchar(20), 
@edad varchar(2), @correo varchar(50), @clave varchar(50), @telefono varchar(30))
as
	begin
		update [Accounts].[Company] set
		company_name = isnull(@nombre, company_name),
		company_age = isnull(@edad, company_age),
		company_email = isnull(@correo, company_email),
		company_password = isnull(@clave, company_password),
		company_phone= isnull(@telefono, company_phone)
		where company_id = @id
	end
go

-- Get
create or alter proc obtenerEmpresas
as
	begin
		select * from [Accounts].[Company]
	end
go

-- Get{name} -> Obtener empresa por su nombre
create or alter proc obtenerEmpresa(@empresa varchar(50))
as
	begin
		select * from [Accounts].[Company] where [company_name] = @empresa
	end
go

-- Delete{id}
create or alter proc eliminarEmpresa(@id int)
as
	delete from [Accounts].[Company] where [company_id] = @id
go

----------------------------------------------
----------- Api/Profesional -----------
----------------------------------------------

-- Create
create or alter proc insertarProfesional(@nombre varchar(30), @apellido varchar(30), @correo varchar(30), @clave varchar(30))
as
	begin
		insert into [Accounts].[Profesional]([user_name], [user_lastname], [user_email], [user_password])
		values(@nombre, @apellido, @correo, @clave)
	end
go		

-- Get
create or alter proc obtenerProfesionales
as
	begin
		select * from [Accounts].[Profesional]
	end
go

-- Get{name} -> Obtener un usuario tipo profesional por su nombre
create or alter proc obtenerProfesional(@nombre varchar(30))
as
	select * from [Accounts].[Profesional] where [user_name] = @nombre
go

-- Delete{id} -> Desactivar cuenta

-- Delete{id} -> Eliminar cuenta por completo
create or alter proc eliminarCuentaProfesional(@id int)
as
	begin
		delete from [Accounts].[Profesional] where [user_id] = @id
	end
go

--------------------------------------------
------------ Api/Sectors ------------
--------------------------------------------

-- Get
create or alter proc obtenerSectores
as
	begin
		select * from [Company].[Sectors]
	end
go

--------------------------------------
------------ Api/Jornadas ------------
--------------------------------------

-- Get
create or alter proc obtenerJornadas
as
	begin
		select * from [Company].[Jornadas]
	end
go

------------------------------------
----------- Api/Business -----------
------------------------------------

-- Post
create or alter proc crearNegocio(@sector varchar(20), @nombre varchar(50), @descripcion varchar(50), @localidad varchar(20))
as
	begin
		insert into [Company].[Business](sector_id, business_name, business_description, business_location)
		values(@sector, @nombre, @descripcion, @localidad)
	end
go

-- Vista para get
create or alter view vistaNegocios
as
	select cs.sector_description Sector, cb.business_name, cb.business_description, cb.business_location
	from [Company].[Business] cb

	inner join [Company].[Sectors] cs on cb.sector_id = cs.sector_id
go

-- Get
create or alter proc obtenerNegocios
as
	begin
		select * from vistaNegocios
	end
go

---------------------------------------
------------ Api/Task ------------
---------------------------------------
-- Get{id}
create or alter proc obtenerActividadesTerminadasPorEmpresa(@id int)
as
	begin
		select * from [Company].[Tasks] 
		where company_id = @id and (fechaTerminada != '')
	end
go

-- Get{id}
create or alter proc obtenerActividadesPorEmpresa(@id int)
as
	begin
		select * from [Company].[Tasks] 
		where company_id = @id and (fechaTerminada is null)
	end
go

-- Post
create or alter proc crearActividad(@id int, @titulo varchar(50))
as
	begin
		insert into [Company].[Tasks](company_id, title, fechaInicio)
		values(@id, @titulo, convert(date, getdate()))
	end
go

-- Edit
create or alter proc editarActividad(@idTask int, @titulo varchar(50))
as
	begin
		update [Company].[Tasks]
		set title = @titulo
		where task_id = @idTask
	end
go

-- Delete -> Update
create or alter proc actividadTerminada(@idTask int)
as
	begin
		update [Company].[Tasks] set
		fechaTerminada = convert(date, getdate())
		where task_id = @idTask
	end
go

-- Delete
create or alter proc eliminarActividadesPorEmpresa(@id int)
as
	begin
		delete from [Company].[Tasks] 
		where company_id = @id and (fechaTerminada is null)
	end
go

-- Limpiar Actividades Completas -> Delete
create or alter proc eliminarActividadesCompletasPorEmpresa(@id int)
as
	begin
		delete from [Company].[Tasks] 
		where company_id = @id and (fechaTerminada != '')
	end
go


---------------------------------------
------------ Api/Employees ------------
---------------------------------------

-- Create / Agregar empleados al negocio


--------------------------------------------
------------ Api/Advertisements ------------
--------------------------------------------

-- Create
create or alter proc crearAnuncio(@titulo varchar(50), @id_empresa int, @descripcion text, @tipoJornada int)
as
	begin
		insert into [Company].[Advertisements](title, company_id, [description], tipoJornadaId, fechaCreada)
		values (@titulo, @id_empresa, @descripcion, @tipoJornada, convert(date, getdate()))
	end
go

-- Edit


-- Vista para el get
create or alter view vistaAnuncios 
as 
	select ca.title Titulo, ca.[description] Descripcion, ac.company_name Empresa, 
	cj.jornada tipoJornada, ca.fechaCreada fechaCreacion
	from [Company].[Advertisements] ca

	inner join [Company].[Jornadas] cj on ca.tipoJornadaId = cj.tipoJornadaId
	inner join [Accounts].[Company] ac on ca.[company_id] = ac.[company_id]
go

-- Get
create or alter proc obtenerAnuncios
as
	begin
		select * from vistaAnuncios
	end
go

-- Get{title}
create or alter proc obtenerAnuncioPorTitulo(@titulo varchar(50))
as
	begin
		if exists(select * from vistaAnuncios where Titulo = @titulo)
			select * from vistaAnuncios where Titulo = @titulo
		else
			select 'El anuncio que intentas encontrar, no existe' Mensaje
	end
go

-- Get{id}
create or alter proc obtenerAnuncioPorEmpresa(@id varchar(2))
as
	begin
		if exists(select * from [Company].[Advertisements] where company_id = @id)
			select * from [Company].[Advertisements] where company_id = @id
		else
			select 'El anuncio que intentas encontrar, no existe' Mensaje
	end
go

-- Delete{id} -> Los anuncios son temporales
create or alter proc eliminarAnuncio(@id varchar(2))
as
	begin
		delete from [Company].[Advertisements] where jobId = @id
	end
go

--------------------------------------
------------ Api/Jornadas ------------
--------------------------------------

-- Get
create or alter proc obtenerJornadas
as
	begin
		select * from [Company].[Jornadas]
	end
go