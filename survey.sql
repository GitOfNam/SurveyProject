USE [DATA_EOFFICE_BG_MARITIMEBANK]
GO
/****** Object:  Table [dbo].[SurveyPage]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SurveyPage](
	[ID] [uniqueidentifier] NOT NULL,
	[SurveyTableId] [uniqueidentifier] NOT NULL,
	[Title] [nvarchar](255) NULL,
	[Status] [smallint] NOT NULL,
	[Index] [int] NULL,
	[Modified] [datetime] NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[Created] [datetime] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[Options] [nvarchar](max) NULL,
 CONSTRAINT [PK_SurveyPage] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[SurveyPage] ADD  CONSTRAINT [DF_SurveyPage_Status]  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [dbo].[SurveyPage] ADD  CONSTRAINT [DF_SurveyPage_Modified]  DEFAULT (getdate()) FOR [Modified]
GO
ALTER TABLE [dbo].[SurveyPage] ADD  CONSTRAINT [DF_SurveyPage_Created]  DEFAULT (getdate()) FOR [Created]
GO
ALTER TABLE [dbo].[SurveyPage] ADD  CONSTRAINT [DF_SurveyPage_Options]  DEFAULT ('{"TitleAlignment":"left"}') FOR [Options]
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyQuestion_Insert]    Script Date: 5/4/2023 5:43:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[vuthao_Survey_SurveyQuestion_Insert]
	@Type int,
	@SurveyTableId uniqueidentifier = null,
	@SurveyPageId uniqueidentifier = null,
	@SurveyGroupId uniqueidentifier = null,
	@Title nvarchar(4000),
	@Description nvarchar(max) = null,
	@Value nvarchar(max) = null,
	@Status tinyint = 1,
	@Required bit = 0,
	@Formula nvarchar(2000) = null,
	@FormulaMessage nvarchar(2000) = null,
	--@Index int,
	@CreatedBy uniqueidentifier = null,
	@Options nvarchar(max) = null,
	@DisableDoAgain bit = 0,
	@IsScoring bit = 0,
	@ValidValue nvarchar(max)=null,
	@Score smallint=null,
	@Position varchar(8) = 'after',
	@QuestionId uniqueidentifier = null,
	@IsReturnData bit = 1,		-- Có trả về dữ liệu không
	@ReturnID uniqueidentifier OUTPUT
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		DECLARE @ErrorMessage NVARCHAR(1000);
		DECLARE @Created DATETIME = GETDATE();
		DECLARE @ID uniqueidentifier = NEWID();

		DECLARE @NewIndex int;
		IF(@SurveyPageId IS NULL AND @SurveyTableId IS NULL)
		BEGIN
			SELECT @ErrorMessage = 'DU LIEU TRUYEN VAO KHONG DUNG';
			RAISERROR(@ErrorMessage, 16, 1)
		END

		IF(@SurveyPageId IS NOT NULL)
		BEGIN
			SET @SurveyTableId = (SELECT TOP 1 [SurveyTableId] FROM [dbo].[SurveyPage] WHERE [ID] = @SurveyPageId);
			IF(@SurveyTableId IS NULL)
			BEGIN
				SELECT @ErrorMessage = 'KHONG TIM THAY BANG KHAO SAT';
				RAISERROR(@ErrorMessage, 16, 1)
			END
		END
		ELSE
		BEGIN
			IF(@SurveyTableId IS NOT NULL)
			BEGIN
				SET @SurveyPageId = (SELECT TOP 1 [ID] FROM [dbo].[SurveyPage] WHERE [SurveyTableId] = @SurveyTableId and [Status] <> -2 ORDER BY [Index] DESC );
				IF(@SurveyPageId IS NULL)
				BEGIN
					SELECT @ErrorMessage = 'KHONG TIM THAY TRANG KHAO SAT';
					RAISERROR(@ErrorMessage, 16, 1)
				END
			END
		END
		
		-- Tính index mới 
		IF (@QuestionId is null)
		BEGIN
			DECLARE @MaxIndexInNewPage int = 0;
			SET @MaxIndexInNewPage = (SELECT TOP 1 MAX([Index]) from SurveyQuestion where SurveyTableId = @SurveyTableId AND SurveyPageId = @SurveyPageId)

			IF(@MaxIndexInNewPage IS NULL OR @MaxIndexInNewPage = 0)
			BEGIN
				DECLARE @NewPageIndex int;
				SELECT @NewPageIndex = [Index] from SurveyPage where ID = @SurveyPageId;

				DECLARE @BeforPageId uniqueidentifier = null;
				SELECT @BeforPageId = (SELECT TOP 1 ID FROM SurveyPage WHERE [SurveyTableId] = @SurveyTableId AND [Index] < @NewPageIndex ORDER BY [Index] desc)

				IF(@BeforPageId is null)
					SET @NewIndex = 1;
				ELSE
					SET @NewIndex = (SELECT TOP 1 [Index] + 1 from SurveyQuestion where  [SurveyTableId] = @SurveyTableId AND SurveyPageId = @BeforPageId ORDER BY [Index] desc)
			END
			ELSE
			BEGIN
				SET @NewIndex = @MaxIndexInNewPage + 1
			END
		END
		ELSE
		BEGIN
			SET @NewIndex = (SELECT TOP 1 [Index] from SurveyQuestion where ID = @QuestionId order by [Index] desc)

			IF(@Position = 'after')
				SET @NewIndex = @NewIndex +1;
		END
		
		-- Set Option mặc định
		IF(@Options IS NULL)
		BEGIN
			SELECT @Options = [DefaultOptions]
			FROM [dbo].[SurveyQuestionType]
			WHERE [ID] = @Type
		END
		-- Set Status mặc định
		if(@Status is null OR @Status <> -2 )
		begin
			set @Status = 1;
		end

		-- Cập nhật lại index của các câu hỏi tại index mới thêm trở về sau
		UPDATE [dbo].[SurveyQuestion]
		SET [Index] = [Index]+1
		WHERE [SurveyTableId] = @SurveyTableId AND [Index] >= @NewIndex

		-- Insert câu hỏi mới
		INSERT INTO [dbo].[SurveyQuestion] ([ID],[SQTId],[SurveyTableId],[SurveyGroupId],[SurveyPageId],
		[Title],[Description],[Value],[Status],[Required],[Formula],[FormulaMessage],[Index],
		[Modified],[ModifiedBy],[Created],[CreatedBy],[Options],[DisableDoAgain],[IsScoring],[ValidValue],[Score])
		 VALUES
		(@ID,@Type,@SurveyTableId,@SurveyGroupId,@SurveyPageId,@Title,@Description,@Value,@Status,@Required,@Formula,@FormulaMessage,
		@NewIndex,@Created,@CreatedBy,@Created,@CreatedBy,@Options,@DisableDoAgain,@IsScoring,@ValidValue,@Score)

		IF(@IsReturnData = 1)
		BEGIN
		-- Trả về danh sách câu hỏi mới
		SELECT * FROM SurveyQuestion where SurveyTableId = @SurveyTableId and [Status] <> -2 order by [Index] asc

		SET @ReturnID = @ID;
		END
		
		COMMIT
		RETURN 1;
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT @ErrorMessage = 'Error : ' + ERROR_MESSAGE()
		RAISERROR(@ErrorMessage, 16, 1)
		RETURN 0;
	END CATCH
END
Go


/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyBranching_Delete]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyBranching_Delete]
	@ID uniqueidentifier = NULL,
	@SurveyQuestionId uniqueidentifier = null,
	@Type tinyint = NULL	-- 1: Branching , != 1 : Else
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		IF(@ID IS NULL AND @SurveyQuestionId IS NULL)
		BEGIN
			COMMIT;
			RETURN 0;
		END

		DECLARE @tbDeleteBranching table(
			ID uniqueidentifier,
			[Type] tinyint
		);
		INSERT INTO @tbDeleteBranching ([ID],[Type])
		SELECT [ID],[Type] FROM  [dbo].[SurveyBranching]
		WHERE (@ID IS NULL OR  [ID] = @ID OR [ParentId] = @ID)
		AND (@SurveyQuestionId IS NULL OR [SurveyQuestionId] = @SurveyQuestionId)
		AND (@Type IS NULL OR [Type] = @Type)

		SELECT [ID] FROM @tbDeleteBranching

		-- XOA NHANH CHINH VA CAC NHANH CON CUA NO'
		DELETE FROM [dbo].[SurveyBranching]
		WHERE (@ID IS NULL OR  [ID] = @ID OR [ParentId] = @ID)
		AND (@SurveyQuestionId IS NULL OR [SurveyQuestionId] = @SurveyQuestionId)
		AND (@Type IS NULL OR [Type] = @Type)

		IF(EXISTS (SELECT [ID] FROM @tbDeleteBranching))
		BEGIN
			-- XOA CAC QUESTION RELATION MA CO' BRANCHING BI. XOA
			SELECT [ID] FROM [dbo].[SurveyQuestionRelations]
			WHERE [SurveyBranchingId]  IN (SELECT [ID] FROM @tbDeleteBranching )
			AND (@Type IS NULL OR [Type] = @Type)

			DELETE FROM [dbo].[SurveyQuestionRelations]
			WHERE [SurveyBranchingId]  IN (SELECT [ID] FROM @tbDeleteBranching)
			AND( @Type IS NULL OR [Type] = @Type)
		END

		COMMIT
		RETURN 1;
	END TRY
	BEGIN CATCH
		ROLLBACK
		RETURN 0;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyBranching_InserUpdate]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyBranching_InserUpdate]
	@ID uniqueidentifier,
	@ParentId uniqueidentifier = null,
	@SurveyQuestionId uniqueidentifier = null,
	@SubQuestionId varchar(100) = null,
	@RefSQId uniqueidentifier = null,
	@Value nvarchar(255) = null,
	@Condition nvarchar(20) = '=',
	@JumpToSurveyPageId uniqueidentifier = null,
	@JumpToSurveyQuestionId uniqueidentifier = null,
	@Operator varchar(5) = 'AND',
	@IsNext bit = 0,
	@Index int,
	@Type tinyint = 1,
	@ModifiedBy uniqueidentifier = null,
	@IsCreated bit
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		Declare @dtNow Datetime =GetDate();
		DECLARE @HasRelationTo bit = 0;

		IF (@RefSQId IS NULL) 
			SET @RefSQId = @SurveyQuestionId;
		IF(EXISTS (SELECT [ID] FROM [SurveyQuestionRelations] WHERE [ToSurveyQuestionId] = @RefSQId AND [Type] <> @Type))
		BEGIN
			COMMIT
			RETURN 0;
		END
		IF (@IsCreated IS NOT NULL AND @IsCreated = 1)
			BEGIN
			UPDATE [dbo].[SurveyBranching]
			SET SurveyQuestionId = @SurveyQuestionId,Value = @Value,Condition = @Condition,
			JumpToSurveyPageId = @JumpToSurveyPageId,JumpToSurveyQuestionId = @JumpToSurveyQuestionId,
			Operator = @Operator,[Index] = @Index,Modified = @dtNow,ModifiedBy = @ModifiedBy,[Type] = @Type,[RefSQId] = @RefSQId
			WHERE [ID] = @ID

			SELECT TOP 1 * FROM [dbo].[SurveyBranching]
			WHERE [ID] = @ID AND [SurveyBranching].[Type] = @Type
			END
		ELSE
			BEGIN
			SET @ID = NEWID();
			INSERT INTO [dbo].[SurveyBranching] ([ID],[ParentId],[SurveyQuestionId],[SubQuestionId],[Value],
			[Condition],[JumpToSurveyPageId],[JumpToSurveyQuestionId],[Operator],[IsNext],[Index],[Modified],
			[ModifiedBy],[Created],[CreatedBy],[Type],[RefSQId])
			VALUES(@ID,@ParentId,@SurveyQuestionId,@SubQuestionId,@Value,@Condition,@JumpToSurveyPageId,
			@JumpToSurveyQuestionId,@Operator,@IsNext,@Index,@dtNow,@ModifiedBy,@dtNow,@ModifiedBy,@Type,@RefSQId);

			SELECT TOP 1 * FROM [dbo].[SurveyBranching]
			WHERE [ID] = @ID AND [SurveyBranching].[Type] = @Type
			END

		-- TIM PARENTID CUAR ROW MOI INSERT UPDATE ( K LAY' TU CLIENT)
		SELECT TOP 1 @ParentId = [SurveyBranching].[ParentId] 	FROM [dbo].[SurveyBranching]
		WHERE [ID] = @ID AND [SurveyBranching].[Type] = @Type

		-- NEU ROW INSERT UPDATE LA MAIN BRANCHING THI XU LY' DOI VOI SurveyQuestionRelation
		IF(@ParentId IS NULL)
		BEGIN
			-- XOA CAC RELATION KHONG DUOC CHON. TU TREEVIEW
			DELETE FROM [dbo].[SurveyQuestionRelations]
			WHERE [SurveyBranchingId] = @ID

			INSERT [dbo].[SurveyQuestionRelations] ([ID],[SurveyBranchingId],[SurveyQuestionId],[ToSurveyQuestionId],[Type])
			VALUES (NEWID(),@ID,@SurveyQuestionId,@JumpToSurveyQuestionId,@Type)
		END

		SELECT * FROM [dbo].[SurveyQuestionRelations]
		WHERE [SurveyBranchingId] = @ID

		COMMIT
		RETURN 1;
	END TRY
	BEGIN CATCH
		ROLLBACK
		RETURN 0;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyBranching_InserUpdate_BK]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyBranching_InserUpdate_BK]
	@ID uniqueidentifier,
	@ParentId uniqueidentifier = null,
	@SurveyQuestionId uniqueidentifier = null,
	@SubQuestionId varchar(100) = null,
	@Value nvarchar(255) = null,
	@Condition nvarchar(20) = '=',
	@JumpToSurveyPageId uniqueidentifier = null,
	@JumpToSurveyQuestionId uniqueidentifier = null,
	@Operator varchar(5) = 'AND',
	@IsNext bit = 0,
	@Index int,
	@ModifiedBy uniqueidentifier = null,
	@IsCreated bit
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		Declare @dtNow Datetime =GetDate();
		DECLARE @HasRelationTo bit = 0;

		IF(EXISTS (SELECT [ID] FROM [SurveyQuestionRelations] WHERE [ToSurveyQuestionId] = @SurveyQuestionId))
		BEGIN
			COMMIT
			RETURN 0;
		END
		IF (@IsCreated IS NOT NULL AND @IsCreated = 1)
			BEGIN
			UPDATE [dbo].[SurveyBranching]
			SET SurveyQuestionId = @SurveyQuestionId,Value = @Value,Condition = @Condition,
			JumpToSurveyPageId = @JumpToSurveyPageId,JumpToSurveyQuestionId = @JumpToSurveyQuestionId,
			Operator = @Operator,[Index] = @Index,Modified = @dtNow,ModifiedBy = @ModifiedBy
			WHERE [ID] = @ID

			SELECT TOP 1 * FROM [dbo].[SurveyBranching]
			WHERE [ID] = @ID AND [SurveyBranching].[Type] = 1
			END
		ELSE
			BEGIN
			DECLARE @NEWID UNIQUEIDENTIFIER = NEWID();
			INSERT INTO [dbo].[SurveyBranching] ([ID],[ParentId],[SurveyQuestionId],[SubQuestionId],[Value],
			[Condition],[JumpToSurveyPageId],[JumpToSurveyQuestionId],[Operator],[IsNext],[Index],[Modified],
			[ModifiedBy],[Created],[CreatedBy])
			VALUES(@NEWID,@ParentId,@SurveyQuestionId,@SubQuestionId,@Value,@Condition,@JumpToSurveyPageId,
			@JumpToSurveyQuestionId,@Operator,@IsNext,@Index,@dtNow,@ModifiedBy,@dtNow,@ModifiedBy);

			SELECT TOP 1 * FROM [dbo].[SurveyBranching]
			WHERE [ID] = @NEWID AND [SurveyBranching].[Type] = 1
			END
		COMMIT
		RETURN 1;
	END TRY
	BEGIN CATCH
		ROLLBACK
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyBranching_Select]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyBranching_Select]
	@ID uniqueidentifier = null,
	@ParentId uniqueidentifier = null,
	@SurveyQuestionId uniqueidentifier = null,
	@SubQuestionId varchar(100)  = null,
	@SurveyTableId uniqueidentifier = null,
	@Type tinyint = 1 -- 1 : Re nhanh Logic, 2 : Quan he , 0 : All
AS
BEGIN
	SELECT SB.* 
	FROM [dbo].[SurveyBranching] SB
	INNER JOIN [dbo].[SurveyQuestion] SQ ON (SB.[SurveyQuestionId] = SQ.ID)
	WHERE (@ID IS NULL OR SB.[ID] = @ID)
	AND (@ParentId IS NULL OR SB.[ParentId] = @ParentId)
	AND (@SurveyQuestionId IS NULL OR SB.[SurveyQuestionId] = @SurveyQuestionId)
	AND (@SubQuestionId IS NULL OR SB.[SubQuestionId] = @SubQuestionId)
	AND (@SurveyTableId IS NULL OR SQ.SurveyTableId = @SurveyTableId)
	AND (@Type IS NULL OR @Type = 0 OR SB.[Type] = @Type)
	AND (SQ.[Status] <> -2)
	ORDER BY [Index] ASC
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyBranchingRelation_InsertUpdate]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyBranchingRelation_InsertUpdate]
	@ID uniqueidentifier,
	@ParentId uniqueidentifier = null,
	@SurveyQuestionId uniqueidentifier = null,
	@SubQuestionId varchar(100) = null,
	@RefSQId uniqueidentifier = null,
	@Value nvarchar(255) = null,
	@Condition nvarchar(20) = '=',
	@Operator varchar(5) = 'AND',
	@IsNext bit = 0,
	@Index int,
	@Type tinyint = 2,
	@ModifiedBy uniqueidentifier = null,
	@IsCreated bit,
	@ArrayRelationQuestionId varchar(max) = null
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		Declare @dtNow Datetime =GetDate();
		DECLARE @SurveyTableId uniqueidentifier;
		IF (@RefSQId IS NULL)
			SET @RefSQId = @SurveyQuestionId
		SELECT @SurveyTableId = [SurveyTableId] FROM SurveyQuestion WHERE [ID] = @SurveyQuestionId

		IF(@Type = 1)
		BEGIN
			IF(EXISTS (SELECT [ID] FROM [SurveyQuestionRelations] WHERE [ToSurveyQuestionId] = @RefSQId AND [Type] <> @Type))
			BEGIN
				COMMIT
				RETURN 0;
			END
		END

		-- INSERT UPDATE BRANCHING CUA RELATION
		IF (@IsCreated IS NOT NULL AND @IsCreated = 1)
		BEGIN
			IF(NOT EXISTS (SELECT [ID] FROM [SurveyBranching] WHERE [ID] = @ID))
			BEGIN
				COMMIT;
				RETURN 0;
			END

			UPDATE [dbo].[SurveyBranching]
			SET RefSQId = @RefSQId,[Value] = @Value,Condition = @Condition,
			Operator = @Operator,[Index] = @Index,Modified = @dtNow,ModifiedBy = @ModifiedBy
			WHERE [ID] = @ID
		END
		ELSE
		BEGIN
			SET @ID = NEWID();

			IF(@SurveyQuestionId IS NULL AND @ParentId IS NOT NULL)
			BEGIN
				SET @SurveyQuestionId = (SELECT TOP 1 [SurveyBranching].[SurveyQuestionId] FROM [SurveyBranching] WHERE [ID] = @ParentId)
			END
			

			INSERT INTO [dbo].[SurveyBranching] ([ID],[ParentId],[SurveyQuestionId],[SubQuestionId],[Value],
			[Condition],[Operator],[IsNext],[Index],[Type],[Modified],[ModifiedBy],[Created],[CreatedBy],[RefSQId])
			VALUES(@ID,@ParentId,@SurveyQuestionId,@SubQuestionId,@Value,@Condition,@Operator,@IsNext,@Index,@Type,@dtNow,@ModifiedBy,@dtNow,@ModifiedBy,@RefSQId);
		END

		-- TIM PARENTID CUAR ROW MOI INSERT UPDATE ( K LAY' TU CLIENT)
		SELECT TOP 1 @ParentId = [SurveyBranching].[ParentId] 	FROM [dbo].[SurveyBranching]
		WHERE [ID] = @ID AND [SurveyBranching].[Type] = @Type

		-- NEU ROW INSERT UPDATE LA MAIN BRANCHING THI XU LY' DOI VOI SurveyQuestionRelation
		IF(@ParentId IS NULL)
		BEGIN
			IF(@ArrayRelationQuestionId IS NULL OR @ArrayRelationQuestionId = '')
			BEGIN
				DELETE FROM [dbo].[SurveyQuestionRelations]
				WHERE [SurveyBranchingId] = @ID 
			END
			ELSE
			BEGIN
				DECLARE @tbToRelationQuestionId TABLE(
					[Item] nvarchar(4000)
				);

				INSERT INTO @tbToRelationQuestionId ([Item])
				SELECT [Item] FROM [dbo].[Split](@ArrayRelationQuestionId,'|');

				-- XOA CAC RELATION KHONG DUOC CHON. TU TREEVIEW
				DELETE FROM [dbo].[SurveyQuestionRelations]
				WHERE [SurveyBranchingId] = @ID AND [SurveyQuestionRelations].[ToSurveyQuestionId] NOT IN (SELECT [Item] FROM @tbToRelationQuestionId)

				-- UPDATE TYPE CHO RELATION
				UPDATE [dbo].[SurveyQuestionRelations]
				SET [Type] = @Type
				WHERE [SurveyBranchingId] = @ID

				DECLARE @tbQuestionIdInsert table(
				[ID] uniqueidentifier);

				--IF(@Type = 1)
				--BEGIN
				--	INSERT INTO @tbQuestionIdInsert
				--	SELECT [ID] FROM [dbo].[SurveyQuestion]
				--	INNER JOIN @tbToRelationQuestionId as ListQuestionRelationId ON [SurveyQuestion].[ID] =CAST(ListQuestionRelationId.[Item] AS uniqueidentifier)
				--	-- Kiểm tra ToQuestionID không nằm trong danh sách đã insert rồi của branching này
				--	where [SurveyQuestion].ID not in (SELECT [SurveyQuestionRelations].[ToSurveyQuestionId] FROM [dbo].[SurveyQuestionRelations] WHERE [SurveyBranchingId] = @ID)
				--	AND [SurveyQuestion].[Status] <> -2	-- Bị xóa
				--	-- Kiểm tra ToQuestionID không nằm trong danh sách ToQuestionID nào mà Type khác type đang insert
				--	AND [SurveyQuestion].ID NOT IN (SELECT [SurveyQuestionRelations].ToSurveyQuestionId FROM [dbo].[SurveyQuestionRelations]
				--									INNER JOIN [SurveyQuestion] SQ2 ON SQ2.[ID] = [SurveyQuestionRelations].ToSurveyQuestionId
				--									WHERE SQ2.SurveyTableId = @SurveyTableId AND [SurveyQuestionRelations].[Type] <> @Type)
				--END
				--ELSE
				IF(@Type <> 1)
				BEGIN
					INSERT INTO @tbQuestionIdInsert
					SELECT [ID] FROM [dbo].[SurveyQuestion]
					INNER JOIN @tbToRelationQuestionId as ListQuestionRelationId ON [SurveyQuestion].[ID] =CAST(ListQuestionRelationId.[Item] AS uniqueidentifier)
					-- Kiểm tra ToQuestionID không nằm trong danh sách đã insert rồi của branching này
					where [SurveyQuestion].ID not in (SELECT [SurveyQuestionRelations].[ToSurveyQuestionId] FROM [dbo].[SurveyQuestionRelations] WHERE [SurveyBranchingId] = @ID)
					AND [SurveyQuestion].[Status] <> -2	-- Bị xóa
					-- Kiểm tra ToQuestionID không nằm trong danh sách ToQuestionID nào mà Type khác type đang insert
					--AND [SurveyQuestion].ID NOT IN (SELECT [SurveyQuestionRelations].SurveyQuestionId FROM [dbo].[SurveyQuestionRelations]
					--								INNER JOIN [SurveyQuestion] SQ2 ON SQ2.[ID] = [SurveyQuestionRelations].SurveyQuestionId
					--								WHERE SQ2.SurveyTableId = @SurveyTableId AND [SurveyQuestionRelations].[Type] <> @Type)
					AND [SurveyQuestion].ID NOT IN (SELECT [SurveyBranching].[RefSQId]
													FROM [dbo].[SurveyBranching]
													INNER JOIN [SurveyQuestion] SQ2 ON SQ2.[ID] = [SurveyBranching].[RefSQId]
													WHERE SQ2.SurveyTableId = @SurveyTableId AND [SurveyBranching].[Type] <> @Type)
				END

				

				-- LAY ID CAU HOI DUOC CHON VA CHUA DUOC INSERT DE INSERT
				Declare cs1 Cursor for (select [ID] from @tbQuestionIdInsert)
				Open cs1
				Declare @ToQuestionId nvarchar(max);
				Fetch next From cs1 into @ToQuestionId
				While @@Fetch_Status=0
				BEGIN
					IF(@ToQuestionId <> @SurveyQuestionId)
					BEGIN
						INSERT [dbo].[SurveyQuestionRelations] ([ID],[SurveyBranchingId],[SurveyQuestionId],[ToSurveyQuestionId],[Type])
						VALUES (NEWID(),@ID,@SurveyQuestionId,@ToQuestionId,@Type)
					END
					Fetch next From cs1 into @ToQuestionId
				END
				CLOSE cs1;
				Deallocate cs1;
			END
		END

		SELECT TOP 1 * FROM [dbo].[SurveyBranching] 
		WHERE [ID] = @ID AND [Type]  = @Type

		IF(@ParentId IS NULL)
		BEGIN
			DECLARE @tbRelation Table(
			[ID] uniqueidentifier,
			[SurveyBranchingId] uniqueidentifier,
			[SurveyQuestionId] uniqueidentifier,
			[ToSurveyQuestionId] uniqueidentifier,
			[Type] tinyint
			)

			INSERT INTO @tbRelation
			SELECT * FROM [dbo].[SurveyQuestionRelations]
			WHERE [SurveyBranchingId] = @ID

			IF(NOT EXISTS (SELECT [ID] FROM @tbRelation))
			BEGIN
				ROLLBACK
				RETURN 0;
			END

			SELECT * FROM @tbRelation
		END

		COMMIT
		RETURN 1;
	END TRY
	BEGIN CATCH
		ROLLBACK
		RETURN 0;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyBranchingRelation_InsertUpdate_BK]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyBranchingRelation_InsertUpdate_BK]
	@ID uniqueidentifier,
	@ParentId uniqueidentifier = null,
	@SurveyQuestionId uniqueidentifier = null,
	@SubQuestionId varchar(100) = null,
	@Value nvarchar(255) = null,
	@Condition nvarchar(20) = '=',
	@Operator varchar(5) = 'AND',
	@IsNext bit = 0,
	@Index int,
	@Type tinyint = 2,
	@ModifiedBy uniqueidentifier = null,
	@IsCreated bit,
	@ArrayRelationQuestionId varchar(max) = null,
	@QuestionRelationType tinyint
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		Declare @dtNow Datetime =GetDate();
		DECLARE @SurveyTableId uniqueidentifier;

		SELECT @SurveyTableId = [SurveyTableId] FROM SurveyQuestion WHERE [ID] = @SurveyQuestionId

		-- INSERT UPDATE BRANCHING CUA RELATION
		IF (@IsCreated IS NOT NULL AND @IsCreated = 1)
		BEGIN
			IF(NOT EXISTS (SELECT [ID] FROM [SurveyBranching] WHERE [ID] = @ID))
			BEGIN
				COMMIT;
				RETURN 0;
			END

			UPDATE [dbo].[SurveyBranching]
			SET [Value] = @Value,Condition = @Condition,
			Operator = @Operator,[Index] = @Index,Modified = @dtNow,ModifiedBy = @ModifiedBy
			WHERE [ID] = @ID
		END
		ELSE
		BEGIN
			SET @ID = NEWID();

			IF(@SurveyQuestionId IS NULL AND @ParentId IS NOT NULL)
			BEGIN
				SET @SurveyQuestionId = (SELECT TOP 1 [SurveyBranching].[SurveyQuestionId] FROM [SurveyBranching] WHERE [ID] = @ParentId)
			END
			

			INSERT INTO [dbo].[SurveyBranching] ([ID],[ParentId],[SurveyQuestionId],[SubQuestionId],[Value],
			[Condition],[Operator],[IsNext],[Index],[Type],[Modified],[ModifiedBy],[Created],[CreatedBy])
			VALUES(@ID,@ParentId,@SurveyQuestionId,@SubQuestionId,@Value,@Condition,@Operator,@IsNext,@Index,@Type,@dtNow,@ModifiedBy,@dtNow,@ModifiedBy);
		END

		-- TIM PARENTID CUAR ROW MOI INSERT UPDATE ( K LAY' TU CLIENT)
		SELECT TOP 1 @ParentId = [SurveyBranching].[ParentId] 	FROM [dbo].[SurveyBranching]
		WHERE [ID] = @ID AND [SurveyBranching].[Type] <> @Type

		-- NEU ROW INSERT UPDATE LA MAIN BRANCHING THI XU LY' DOI VOI SurveyQuestionRelation
		IF(@ParentId IS NULL)
		BEGIN
			IF (@ArrayRelationQuestionId IS NULL OR @ArrayRelationQuestionId = '')
			BEGIN
				COMMIT
				RETURN 0;
			END
			
			IF(@ArrayRelationQuestionId IS NULL OR @ArrayRelationQuestionId = '')
			BEGIN
				DELETE FROM [dbo].[SurveyQuestionRelations]
				WHERE [SurveyBranchingId] = @ID 
			END
			ELSE
			BEGIN
				DECLARE @tbToRelationQuestionId TABLE(
					[Item] nvarchar(4000)
				);

				INSERT INTO @tbToRelationQuestionId ([Item])
				SELECT [Item] FROM [dbo].[Split](@ArrayRelationQuestionId,'|');

				-- XOA CAC RELATION KHONG DUOC CHON. TU TREEVIEW
				DELETE FROM [dbo].[SurveyQuestionRelations]
				WHERE [SurveyBranchingId] = @ID AND [SurveyQuestionRelations].[ToSurveyQuestionId] NOT IN (SELECT [Item] FROM @tbToRelationQuestionId)

				-- UPDATE TYPE CHO RELATION
				UPDATE [dbo].[SurveyQuestionRelations]
				SET [Type] = @Type
				WHERE [SurveyBranchingId] = @ID

				-- LAY ID CAU HOI DUOC CHON VA CHUA DUOC INSERT DE INSERT
				Declare cs1 Cursor for (select [ID] from [dbo].[SurveyQuestion]
										INNER JOIN @tbToRelationQuestionId as ListQuestionRelationId ON [SurveyQuestion].[ID] =CAST(ListQuestionRelationId.[Item] AS uniqueidentifier)
										where [SurveyQuestion].ID not in (SELECT [SurveyQuestionRelations].[ToSurveyQuestionId] FROM [dbo].[SurveyQuestionRelations] WHERE [SurveyBranchingId] = @ID)
										AND [SurveyQuestion].[Status] <> -2
										AND [SurveyQuestion].ID NOT IN (SELECT [SurveyBranching].[SurveyQuestionId] FROM [dbo].[SurveyBranching]
																		INNER JOIN [SurveyQuestion] SQ2 ON SQ2.[ID] = [SurveyBranching].[SurveyQuestionId]
																		WHERE SQ2.SurveyTableId = @SurveyTableId AND [SurveyBranching].[Type] =1))
				Open cs1
				Declare @ToQuestionId nvarchar(max);
				Fetch next From cs1 into @ToQuestionId
				While @@Fetch_Status=0
				BEGIN
					IF(@ToQuestionId <> @SurveyQuestionId)
					BEGIN
						INSERT [dbo].[SurveyQuestionRelations] ([ID],[SurveyBranchingId],[SurveyQuestionId],[ToSurveyQuestionId],[Type])
						VALUES (NEWID(),@ID,@SurveyQuestionId,@ToQuestionId,@Type)
					END
					Fetch next From cs1 into @ToQuestionId
				END
				CLOSE cs1;
				Deallocate cs1;
			END
		END

		SELECT TOP 1 * FROM [dbo].[SurveyBranching] 
		WHERE [ID] = @ID AND [Type] <> 1

		IF(@ParentId IS NULL)
		BEGIN
			DECLARE @tbRelation Table(
			[ID] uniqueidentifier,
			[SurveyBranchingId] uniqueidentifier,
			[SurveyQuestionId] uniqueidentifier,
			[ToSurveyQuestionId] uniqueidentifier,
			[Type] tinyint
			)

			INSERT INTO @tbRelation
			SELECT * FROM [dbo].[SurveyQuestionRelations]
			WHERE [SurveyBranchingId] = @ID

			IF(NOT EXISTS (SELECT [ID] FROM @tbRelation))
			BEGIN
				ROLLBACK
				RETURN 0;
			END

			SELECT * FROM @tbRelation
		END

		COMMIT
		RETURN 1;
	END TRY
	BEGIN CATCH
		ROLLBACK
		RETURN 0;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyBranchingRelation_InsertUpdate_TEST]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyBranchingRelation_InsertUpdate_TEST]
	@ID uniqueidentifier,
	@ParentId uniqueidentifier = null,
	@SurveyQuestionId uniqueidentifier = null,
	@SubQuestionId varchar(100) = null,
	@Value nvarchar(255) = null,
	@Condition nvarchar(20) = '=',
	@Operator varchar(5) = 'AND',
	@IsNext bit = 0,
	@Index int,
	@Type tinyint = 2,
	@ModifiedBy uniqueidentifier = null,
	@IsCreated bit,
	@ArrayRelationQuestionId varchar(max) = null
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		Declare @dtNow Datetime =GetDate();
		DECLARE @SurveyTableId uniqueidentifier;

		SELECT @SurveyTableId = [SurveyTableId] FROM SurveyQuestion WHERE [ID] = @SurveyQuestionId

		-- INSERT UPDATE BRANCHING CUA RELATION
		IF (@IsCreated IS NOT NULL AND @IsCreated = 1)
		BEGIN
			IF(NOT EXISTS (SELECT [ID] FROM [SurveyBranching] WHERE [ID] = @ID))
			BEGIN
				COMMIT;
				RETURN 0;
			END

			UPDATE [dbo].[SurveyBranching]
			SET [Value] = @Value,Condition = @Condition,
			Operator = @Operator,[Index] = @Index,Modified = @dtNow,ModifiedBy = @ModifiedBy
			WHERE [ID] = @ID
		END
		ELSE
		BEGIN
			SET @ID = NEWID();

			IF(@SurveyQuestionId IS NULL AND @ParentId IS NOT NULL)
			BEGIN
				SET @SurveyQuestionId = (SELECT TOP 1 [SurveyBranching].[SurveyQuestionId] FROM [SurveyBranching] WHERE [ID] = @ParentId)
			END
			

			INSERT INTO [dbo].[SurveyBranching] ([ID],[ParentId],[SurveyQuestionId],[SubQuestionId],[Value],
			[Condition],[Operator],[IsNext],[Index],[Type],[Modified],[ModifiedBy],[Created],[CreatedBy])
			VALUES(@ID,@ParentId,@SurveyQuestionId,@SubQuestionId,@Value,@Condition,@Operator,@IsNext,@Index,@Type,@dtNow,@ModifiedBy,@dtNow,@ModifiedBy);
		END

		-- TIM PARENTID CUAR ROW MOI INSERT UPDATE ( K LAY' TU CLIENT)
		SELECT TOP 1 @ParentId = [SurveyBranching].[ParentId] 	FROM [dbo].[SurveyBranching]
		WHERE [ID] = @ID AND [SurveyBranching].[Type] = @Type

		-- NEU ROW INSERT UPDATE LA MAIN BRANCHING THI XU LY' DOI VOI SurveyQuestionRelation
		IF(@ParentId IS NULL)
		BEGIN
			IF(@ArrayRelationQuestionId IS NULL OR @ArrayRelationQuestionId = '')
			BEGIN
				DELETE FROM [dbo].[SurveyQuestionRelations]
				WHERE [SurveyBranchingId] = @ID 
			END
			ELSE
			BEGIN
				DECLARE @tbToRelationQuestionId TABLE(
					[Item] nvarchar(4000)
				);

				INSERT INTO @tbToRelationQuestionId ([Item])
				SELECT [Item] FROM [dbo].[Split](@ArrayRelationQuestionId,'|');

				-- XOA CAC RELATION KHONG DUOC CHON. TU TREEVIEW
				DELETE FROM [dbo].[SurveyQuestionRelations]
				WHERE [SurveyBranchingId] = @ID AND [SurveyQuestionRelations].[ToSurveyQuestionId] NOT IN (SELECT [Item] FROM @tbToRelationQuestionId)

				-- UPDATE TYPE CHO RELATION
				UPDATE [dbo].[SurveyQuestionRelations]
				SET [Type] = @Type
				WHERE [SurveyBranchingId] = @ID

				DECLARE @tbQuestionIdInsert table(
				[ID] uniqueidentifier);

				INSERT INTO @tbQuestionIdInsert
					SELECT [ID] FROM [dbo].[SurveyQuestion]
					INNER JOIN @tbToRelationQuestionId as ListQuestionRelationId ON [SurveyQuestion].[ID] =CAST(ListQuestionRelationId.[Item] AS uniqueidentifier)
					-- Kiểm tra ToQuestionID không nằm trong danh sách đã insert rồi của branching này
					where [SurveyQuestion].ID not in (SELECT [SurveyQuestionRelations].[ToSurveyQuestionId] FROM [dbo].[SurveyQuestionRelations] WHERE [SurveyBranchingId] = @ID)
					AND [SurveyQuestion].[Status] <> -2	-- Bị xóa
					-- Kiểm tra ToQuestionID không nằm trong danh sách ToQuestionID nào mà Type khác type đang insert
					AND [SurveyQuestion].ID NOT IN (SELECT [SurveyQuestionRelations].ToSurveyQuestionId FROM [dbo].[SurveyQuestionRelations]
													INNER JOIN [SurveyQuestion] SQ2 ON SQ2.[ID] = [SurveyQuestionRelations].ToSurveyQuestionId
													WHERE SQ2.SurveyTableId = @SurveyTableId AND [SurveyQuestionRelations].[Type] <> @Type)

				-- LAY ID CAU HOI DUOC CHON VA CHUA DUOC INSERT DE INSERT
				Declare cs1 Cursor for (select [ID] from @tbQuestionIdInsert)
				Open cs1
				Declare @ToQuestionId nvarchar(max);
				Fetch next From cs1 into @ToQuestionId
				While @@Fetch_Status=0
				BEGIN
					IF(@ToQuestionId <> @SurveyQuestionId)
					BEGIN
						INSERT [dbo].[SurveyQuestionRelations] ([ID],[SurveyBranchingId],[SurveyQuestionId],[ToSurveyQuestionId],[Type])
						VALUES (NEWID(),@ID,@SurveyQuestionId,@ToQuestionId,@Type)
					END
					Fetch next From cs1 into @ToQuestionId
				END
				CLOSE cs1;
				Deallocate cs1;
			END
		END

		SELECT TOP 1 * FROM [dbo].[SurveyBranching] 
		WHERE [ID] = @ID AND [Type]  = @Type

		IF(@ParentId IS NULL)
		BEGIN
			DECLARE @tbRelation Table(
			[ID] uniqueidentifier,
			[SurveyBranchingId] uniqueidentifier,
			[SurveyQuestionId] uniqueidentifier,
			[ToSurveyQuestionId] uniqueidentifier,
			[Type] tinyint
			)

			INSERT INTO @tbRelation
			SELECT * FROM [dbo].[SurveyQuestionRelations]
			WHERE [SurveyBranchingId] = @ID

			IF(NOT EXISTS (SELECT [ID] FROM @tbRelation))
			BEGIN
				ROLLBACK
				RETURN 0;
			END

			SELECT * FROM @tbRelation
		END

		COMMIT
		RETURN 1;
	END TRY
	BEGIN CATCH
		ROLLBACK
		RETURN 0;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyCategory_Select]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[vuthao_Survey_SurveyCategory_Select]
@UserId varchar(100) = NULL,		-- Id user hiện hành
@Limit int = 10, 
@Offset int = 0
as
begin
	SELECT A.* FROM SurveyCategory A 
	where A.[Status] <> -2
	Order by [Index] ASC
end
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyExportRequest_GetRequest]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		nguyenhn
-- Create date: 21.11.2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyExportRequest_GetRequest] 
@Status smallint = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM [DATA_EOFFICE_BG_MARITIMEBANK].[dbo].[SurveyExportRequest]
	WHERE [Status] = @Status
END

-- exec vuthao_Survey_SurveyExportRequest_GetRequest 0
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyExportRequest_Insert]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		nguyenhn
-- Create date: 21.11.2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyExportRequest_Insert] 
	-- Add the parameters for the stored procedure here
	@SurveyTableId uniqueidentifier,
	@UserId uniqueidentifier,
	@QueryJson nvarchar(4000) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRAN
	BEGIN TRY
		DECLARE @ID int;

		IF(@SurveyTableId is null or @UserId is null or  (NOT EXISTS (SELECT TOP 1 ID FROM SurveyTable WHERE ID = @SurveyTableId)) OR (NOT EXISTS (SELECT TOP 1 ID FROM PersonalProfile WHERE PersonalProfile.ID = @UserId)))
		BEGIN
			COMMIT;
			RETURN 0;
		END
		
		SET @ID = (SELECT TOP 1 [ID] FROM [SurveyExportRequest] WHERE [SurveyTableId] = @SurveyTableId and [UserId] = @UserId and [Status] = 0)
		IF(@ID IS NOT NULL)
		BEGIN
			UPDATE [SurveyExportRequest]
			SET [QueryJson]  = @QueryJson
			where ID = @ID

			SELECT TOP 1 * FROM [dbo].[SurveyExportRequest] WHERE ID = @ID
		END
		ELSE
		BEGIN
			INSERT INTO [dbo].[SurveyExportRequest]([SurveyTableId],[UserId],[QueryJson])		
			VALUES (@SurveyTableId,@UserId,@QueryJson)

			SELECT TOP 1 * FROM [dbo].[SurveyExportRequest] WHERE ID = SCOPE_IDENTITY()
		END
		COMMIT;
		RETURN 1;
	END TRY
	BEGIN CATCH
		ROLLBACK
		RETURN 0;
	END CATCH
END


/*
DECLARE @Result int;
EXEC @Result = vuthao_Survey_SurveyExportRequest_Insert @SurveyTableId ='9075a532-bbca-41a0-8c36-22c383cc9892',@UserId='456909e9-2139-47c0-a944-55db56510928',@QueryJson='{}'
SELECT @Result


SELECT TOP 10 * FROM [DATA_EOFFICE_BG_MARITIMEBANK].[dbo].[SurveyExportRequest] ORDER BY CREATED
*/
-- EXEC vuthao_Survey_SurveyExportRequest_Insert '9075a532-bbca-41a0-8c36-22c383cc9892','EFC0171B-E830-477C-8B81-CE68C9F7E009','{}'


GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyPage_Delete]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyPage_Delete]
	@ID uniqueidentifier,
	@DeleteType int	-- Bằng 1 thì là Xóa trang xóa lun câu hỏi, bằng 0 thì xóa trang nhưng dời câu hỏi								--	xuống trang phía dưới
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		DECLARE @ErrorMessage VARCHAR(2000);
		DECLARE @NextDeletedPageID uniqueidentifier;
		DECLARE @tbDanhSachXoaReNhanh TABLE
			(ID uniqueidentifier);
		DECLARE @tbDanhSachRelation TABLE(ID uniqueidentifier);
		
		-- Kiểm tra xem còn trang nào đang active nữa không
		IF NOT EXISTS(SELECT * FROM [dbo].[SurveyPage] WHERE [Status] = 1 AND [ID]<>@ID)
		BEGIN
			SET @ErrorMessage = 'Khong the xoa trang neu khong con trang nao khac';
			RAISERROR(@ErrorMessage, 16, 1);
		END

		DECLARE @SurveyTableId uniqueidentifier; DECLARE @DeletedIndex int;
		-- Tìm ID bảng khảo sát, và ID của page bị xóa
		SELECT @SurveyTableId = [SurveyTableId],@DeletedIndex = [Index]
		FROM [dbo].[SurveyPage]
		WHERE [ID] = @ID;

		-- Cập nhật status trang (deactive trang)
		UPDATE [dbo].[SurveyPage]
		SET [Status] = -2
		WHERE [ID] = @ID;
		IF(@DeleteType = 0)	
			BEGIN	-- xóa trang nhưng dời câu hỏi xuống trang kế tiếp
				

				-- Tìm ID của trang kế trang bị xóa( dựa trên index trang bị xóa và id bảng khảo sát
				SELECT TOP 1 @NextDeletedPageID = [ID] 
				FROM [dbo].[SurveyPage]
				WHERE [SurveyTableId] = @SurveyTableId AND [Index] > @DeletedIndex AND [Status]=1
				ORDER BY [Index] ASC


				-- Nếu @NextDeletedPageID là null nghĩa là không có trang kế tiếp nó(trang bị xóa đã là trang				-- cuối cùng rồi. Vậy phải chuyển câu hỏi về trang trước.
				IF(@NextDeletedPageID IS NULL)
				BEGIN
					SELECT TOP 1 @NextDeletedPageID = [ID] 
					FROM [dbo].[SurveyPage]
					WHERE [SurveyTableId] = @SurveyTableId AND [Index] < @DeletedIndex AND [Status]=1
					ORDER BY [Index] DESC
				END

				INSERT INTO @tbDanhSachXoaReNhanh (ID)
				SELECT DISTINCT([SurveyBranching].[ID]) FROM [dbo].[SurveyQuestion]
				INNER JOIN [dbo].[SurveyBranching] ON ([SurveyQuestion].[ID] =[SurveyBranching].[JumpToSurveyQuestionId])
				WHERE [SurveyQuestion].[SurveyPageId] = @ID;


				-- Cập nhật lại PageID cho các câu hỏi trong trang bị xóa
				UPDATE [dbo].[SurveyQuestion]
				SET [SurveyPageId] = @NextDeletedPageID
				WHERE [SurveyPageId] = @ID and [SurveyTableId] = @SurveyTableId
			END
		ELSE
			BEGIN	-- Xóa trang xóa lun câu hỏi
				INSERT INTO @tbDanhSachXoaReNhanh (ID)
				SELECT DISTINCT([SurveyBranching].[ID]) FROM [dbo].[SurveyQuestion]
				INNER JOIN [dbo].[SurveyBranching] ON ( [SurveyQuestion].[ID] = [SurveyBranching].SurveyQuestionId OR [SurveyQuestion].[ID] =[SurveyBranching].[JumpToSurveyQuestionId] OR [SurveyQuestion].[ID] = [SurveyBranching].[RefSQId])
				WHERE [SurveyQuestion].[SurveyPageId] = @ID;


				UPDATE [dbo].[SurveyQuestion]
				SET [Status] = -2
				WHERE [SurveyPageId] = @ID and [SurveyTableId] = @SurveyTableId;

				UPDATE [dbo].[SurveyQuestion]
				SET [SurveyQuestion].[Index] = newSQ.NewIndex
				FROM (
					SELECT ROW_NUMBER() OVER(ORDER BY tempSQ.[Index] ASC) AS NewIndex,	tempSQ.[ID]
					FROM [dbo].[SurveyQuestion] tempSQ
					WHERE tempSQ.[SurveyTableId] = @SurveyTableId AND tempSQ.[Status] IN (0,1)
				) newSQ
				WHERE [SurveyQuestion].[ID] = newSQ.ID
			END

		-- Cập nhật lại index các trang sau đó
		UPDATE [dbo].[SurveyPage]
		SET [Index] = [Index]-1
		WHERE [SurveyTableId] = @SurveyTableId AND [Index] > @DeletedIndex AND [Status] <> -2

		IF(NOT EXISTS (SELECT TOP 1 ID FROM [dbo].[SurveyPage] WHERE [SurveyTableId] = @SurveyTableId AND [Status] <> -2))
		BEGIN
			INSERT INTO [dbo].[SurveyPage]([ID],[SurveyTableId],[Title],[Status],[Index])  VALUES (NEWID(),@SurveyTableId,N'Trang 1',1,1)
		END

		SELECT * FROM [dbo].[SurveyPage] WHERE [SurveyTableId] = @SurveyTableID and [Status]<> -2  ORDER BY [Index];

		SELECT * FROM [dbo].[SurveyQuestion] 
		WHERE [SurveyQuestion].[SurveyTableId] = @SurveyTableID and [Status]<> -2
		ORDER BY [SurveyQuestion].[Index]


		

		if(@DeleteType = 0)
		BEGIN
			SELECT * FROM @tbDanhSachXoaReNhanh;
			SELECT * FROM @tbDanhSachRelation;
			SELECT @NextDeletedPageID;

			UPDATE [dbo].[SurveyBranching]
			SET [JumpToSurveyPageId] = @NextDeletedPageID
			WHERE [SurveyBranching].[ID] IN (SELECT tbUpdate.[ID] FROM @tbDanhSachXoaReNhanh tbUpdate)
		END
		ELSE
		BEGIN
			INSERT INTO @tbDanhSachXoaReNhanh (ID)
			SELECT DISTINCT [SurveyBranching].[ID] FROM  [dbo].[SurveyBranching]
			WHERE [SurveyBranching].ParentId IN (SELECT [ID] FROM @tbDanhSachXoaReNhanh)
			AND NOT EXISTS (SELECT TB2.[ID] FROM @tbDanhSachXoaReNhanh TB2 WHERE TB2.[ID] = [SurveyBranching].[ID])

			INSERT INTO @tbDanhSachRelation
			SELECT [ID] FROM [dbo].[SurveyQuestionRelations]
			WHERE [SurveyBranchingId] IN (SELECT [ID] FROM @tbDanhSachXoaReNhanh )

			SELECT * FROM @tbDanhSachXoaReNhanh;
			SELECT * FROM @tbDanhSachRelation;

			DELETE FROM [dbo].[SurveyBranching]
			WHERE [ID] IN (SELECT [ID] FROM @tbDanhSachXoaReNhanh)
			
			DELETE FROM [dbo].[SurveyQuestionRelations]
			WHERE [ID] IN (SELECT [ID] FROM @tbDanhSachRelation)
		END
		
		COMMIT
		return 1;
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT @ErrorMessage = 'Error : ' + ERROR_MESSAGE()
		RAISERROR(@ErrorMessage, 16, 1)
		RETURN 0
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyPage_EditTitle]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyPage_EditTitle]
	@ID uniqueidentifier,
	@Title nvarchar(255),
	@ModifiedBy uniqueidentifier,
	@Options nvarchar(max)
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		DECLARE @ErrorMessage NVARCHAR(1000);
		DECLARE @Modified datetime = getdate();

		IF NOT EXISTS (SELECT * FROM [dbo].[SurveyPage] WHERE [ID]=@ID)
		BEGIN
			SELECT @ErrorMessage = 'KHONG TIM THAY TRANG KHAO SAT';
			RAISERROR(@ErrorMessage,16,1);
			RETURN;
		END

		UPDATE [dbo].[SurveyPage]
		SET [Title] = @Title,[Modified] = @Modified,[ModifiedBy] = @ModifiedBy,[Options]=@Options
		WHERE [ID] = @ID

	COMMIT
	END TRY
	BEGIN CATCH
	ROLLBACK;
	    SELECT @ErrorMessage = 'Error : ' + ERROR_MESSAGE()
	    RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyPage_Insert]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyPage_Insert]
	@SurveyTableId uniqueidentifier=null,
	@Title nvarchar(255)='',
	@Status smallint=1,
	@Position varchar(8) = 'after',
	@PageID uniqueidentifier = null,
	--@Index int,
	@CreatedBy uniqueidentifier=null,
	@Options nvarchar(max) = NULL,
	@IsCopySurveyPage bit = 0		,-- 0 : Khong phai copy, 1 : la copy
	@CopiedPageId uniqueidentifier = null,
	@ReturnID uniqueidentifier OUTPUT
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		DECLARE @ErrorMessage VARCHAR(2000);
		DECLARE @Created datetime = GETDATE();
		DECLARE @ID uniqueidentifier;
		SET @ID  = NEWID();

		IF NOT EXISTS( SELECT * FROM [dbo].[SurveyTable] WHERE [ID] = @SurveyTableId)
		BEGIN
			SELECT @ErrorMessage = N'KHONG TIM THAY BANG KHAO SAT';
			RAISERROR(@ErrorMessage, 16, 1);
		END

		DECLARE @NewIndex int = 0;
		-- Tính index mới 
		IF (@PageID is null)
		BEGIN
			SET @NewIndex = 1;
		END
		ELSE
		BEGIN
			DECLARE @DesPageIndex int = 0;
			SET @DesPageIndex =  (SELECT TOP 1 ([Index]) FROM SurveyPage WHERE SurveyTableId = @SurveyTableId AND ID = @PageID)

			IF(@DesPageIndex IS NULL OR @DesPageIndex  = 0)
			BEGIN
				SELECT @ErrorMessage = N'KHONG TIM THAY TRANG KHAO SAT';
				RAISERROR(@ErrorMessage, 16, 1);
			END

			SET @NewIndex = @DesPageIndex;
			IF(@Position = 'after')
				SET @NewIndex = @NewIndex +1;
		END


		-- Cập nhật lại index của các TRANG tại index mới thêm trở về sau
		UPDATE [dbo].[SurveyPage]
		SET [Index] = [Index]+1
		WHERE [SurveyTableId] = @SurveyTableId AND [Index] >= @NewIndex AND [Status]<>-2


		if(@Status is null)
		begin
			SET @Status = 1;
		end

		IF(@Options IS NOT NULL)
		BEGIN
			INSERT INTO [dbo].[SurveyPage] ([ID],[SurveyTableId],[Title],[Status],[Index],[Modified],[ModifiedBy],[Created],[CreatedBy],[Options])
					VALUES (@ID,@SurveyTableId,@Title,@Status,@NewIndex,@Created,@CreatedBy,@Created,@CreatedBy,@Options);
		END
		ELSE
		BEGIN
			INSERT INTO [dbo].[SurveyPage] ([ID],[SurveyTableId],[Title],[Status],[Index],[Modified],[ModifiedBy],[Created],[CreatedBy])
					VALUES (@ID,@SurveyTableId,@Title,@Status,@NewIndex,@Created,@CreatedBy,@Created,@CreatedBy);
		END

		SELECT * FROM SurveyPage WHERE [SurveyTableId] = @SurveyTableId AND [Status] <> -2 ORDER BY [Index] asc
		SET @ReturnID = @ID;

		IF(@IsCopySurveyPage =1 AND @CopiedPageId IS NOT NULL)
		BEGIN
			INSERT INTO [dbo].[SurveyQuestion] ([ID],[SQTId],[SurveyTableId],[SurveyPageId],[Title],[Description],[Value],[Status],[Required],[Formula],[FormulaMessage],[Index],[ModifiedBy],[CreatedBy],[Options])
			SELECT NEWID() AS ID,[SQTId],[SurveyTableId],@ID as [SurveyPageId],[Title],[Description],[Value],[Status],[Required],[Formula],[FormulaMessage],[Index],[ModifiedBy],[CreatedBy],[Options]
			FROM [dbo].[SurveyQuestion]
			WHERE [SurveyQuestion].[SurveyPageId] = @CopiedPageId
			
			UPDATE tbQuestion
			SET tbQuestion.[Index] = tbQuestion.NewIndex
			FROM (SELECT [SurveyQuestion].[Index], ROW_NUMBER() OVER (ORDER BY [SurveyPage].[Index],[SurveyQuestion].[Index]) AS NewIndex
					FROM [dbo].[SurveyQuestion]
					LEFT JOIN [dbo].[SurveyPage] ON [SurveyQuestion].[SurveyPageId] =[SurveyPage].[ID]
					WHERE  [SurveyPage].[Status] <> -2
						AND [SurveyQuestion].[Status]<>-2
						AND [SurveyQuestion].[SurveyTableId] = @SurveyTableID) tbQuestion


			SELECT * FROM [dbo].[SurveyQuestion] 
			WHERE [SurveyQuestion].[SurveyTableId] = @SurveyTableID AND [Status]<>-2 ORDER BY [Index] asc
		END
		COMMIT
		RETURN 1;
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT @ErrorMessage = 'Error : ' + ERROR_MESSAGE()
		RAISERROR(@ErrorMessage, 16, 1)
		RETURN 0;
	END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyPage_Insert_bk]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyPage_Insert_bk]
	@SurveyTableId uniqueidentifier=null,
	@Title nvarchar(255)='',
	@Status smallint=1,
	@Index int,
	@CreatedBy uniqueidentifier=null,
	@Options nvarchar(max) = NULL,
	@IsCopySurveyPage bit = 0		,-- 0 : Khong phai copy, 1 : la copy
	@CopiedPageId uniqueidentifier = null
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		DECLARE @ErrorMessage VARCHAR(2000);
		DECLARE @Created datetime = GETDATE();
		DECLARE @ID uniqueidentifier;
		SET @ID  = NEWID();

		IF NOT EXISTS( SELECT * FROM [dbo].[SurveyTable] WHERE [ID] = @SurveyTableId)
		BEGIN
			SELECT @ErrorMessage = N'KHONG TIM THAY BANG KHAO SAT';
			RAISERROR(@ErrorMessage, 16, 1);
			RETURN;
		END

		if(@Index is null)
		begin
			SELECT  @Index = (COALESCE(MAX([Index]),0) + 1)
			FROM [dbo].[SurveyPage]
			WHERE [SurveyTableId] = @SurveyTableId
			AND [Status] <> -2
			GROUP BY [SurveyTableId]

			SET @Index = COALESCE(@Index,1);
		end
		else
		begin
			DECLARE @CountIndexDuplicate int;
			SET @CountIndexDuplicate = (SELECT COUNT(*) FROM [dbo].[SurveyPage] 
										WHERE [SurveyTableId] = @SurveyTableId AND [Index]=@Index and [Status]<>-2);

			IF(@CountIndexDuplicate>0)
			BEGIN
				UPDATE [dbo].[SurveyPage]
				SET [Index] = [Index] +1
				WHERE [Index] >= @Index AND [SurveyTableId] = @SurveyTableId
				AND [Status]<>-2
			END
		end

		if(@Status is null)
		begin
			SET @Status = 1;
		end

		IF(@Options IS NOT NULL)
		BEGIN
			INSERT INTO [dbo].[SurveyPage] ([ID],[SurveyTableId],[Title],[Status],[Index],[Modified],[ModifiedBy],[Created],[CreatedBy],[Options])
					VALUES (@ID,@SurveyTableId,@Title,@Status,@Index,@Created,@CreatedBy,@Created,@CreatedBy,@Options);
		END
		ELSE
		BEGIN
			INSERT INTO [dbo].[SurveyPage] ([ID],[SurveyTableId],[Title],[Status],[Index],[Modified],[ModifiedBy],[Created],[CreatedBy])
					VALUES (@ID,@SurveyTableId,@Title,@Status,@Index,@Created,@CreatedBy,@Created,@CreatedBy);
		END

		SELECT * FROM [dbo].[SurveyPage] WHERE [Created] = @Created AND [Index] = @Index;

		IF(@IsCopySurveyPage =1 AND @CopiedPageId IS NOT NULL)
		BEGIN
			INSERT INTO [dbo].[SurveyQuestion] ([ID],[SQTId],[SurveyTableId],[SurveyPageId],[Title],[Description],[Value],[Status],[Required],[Formula],[FormulaMessage],[Index],[ModifiedBy],[CreatedBy],[Options])
			SELECT NEWID() AS ID,[SQTId],[SurveyTableId],@ID as [SurveyPageId],[Title],[Description],[Value],[Status],[Required],[Formula],[FormulaMessage],[Index],[ModifiedBy],[CreatedBy],[Options]
			FROM [dbo].[SurveyQuestion]
			WHERE [SurveyQuestion].[SurveyPageId] = @CopiedPageId
			
			UPDATE tbQuestion
			SET tbQuestion.[Index] = tbQuestion.NewIndex
			FROM (SELECT [SurveyQuestion].[Index], ROW_NUMBER() OVER (ORDER BY [SurveyPage].[Index],[SurveyQuestion].[Index]) AS NewIndex
					FROM [dbo].[SurveyQuestion]
					LEFT JOIN [dbo].[SurveyPage] ON [SurveyQuestion].[SurveyPageId] =[SurveyPage].[ID]
					WHERE  [SurveyPage].[Status] <> -2
						AND [SurveyQuestion].[Status]<>-2
						AND [SurveyQuestion].[SurveyTableId] = @SurveyTableID) tbQuestion


			SELECT * FROM [dbo].[SurveyQuestion] 
			WHERE [SurveyQuestion].[SurveyTableId] = @SurveyTableID ORDER BY [SurveyQuestion].[Index]
		END
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT @ErrorMessage = 'Error : ' + ERROR_MESSAGE()
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyPage_MovePage]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyPage_MovePage]
	@ID uniqueidentifier,
	@Position varchar(8) = 'after',
	@PageId uniqueidentifier = null,
	@ModifiedBy uniqueidentifier
AS
BEGIN
BEGIN TRAN
	BEGIN TRY
		DECLARE @ErrorMessage nvarchar(1000);
		DECLARE @SurveyTableID uniqueidentifier;
		DECLARE @OldIndex int;

		--Tìm Index cũ và SurveyTableID
		SELECT @OldIndex  = [Index],@SurveyTableID = [SurveyTableId]
		FROM [dbo].[SurveyPage]
		WHERE [ID] = @ID;

		DECLARE @NewIndex int = 0;
		-- Tính index mới 
		IF(@PageId IS NULL)
		BEGIN
			COMMIT;
			RETURN 0;
		END
		ELSE
		BEGIN
			DECLARE @DesPageIndex int = 0;
			SET @DesPageIndex =  (SELECT TOP 1 ([Index]) FROM SurveyPage WHERE SurveyTableId = @SurveyTableId AND ID = @PageID)

			IF(@DesPageIndex IS NULL OR @DesPageIndex  = 0)
			BEGIN
				SELECT @ErrorMessage = N'KHONG TIM THAY TRANG KHAO SAT';
				RAISERROR(@ErrorMessage, 16, 1);
			END

			SET @NewIndex = @DesPageIndex;
			IF(@Position = 'after')
				SET @NewIndex = @NewIndex +1;
		END
		
		UPDATE [dbo].[SurveyPage]
		SET [Index] = [Index]+1 
		WHERE [SurveyTableId] = @SurveyTableID
			AND [Index] >= @NewIndex 

		--IF(@OldIndex IS NULL OR @NewIndex < @OldIndex)
		--BEGIN	-- Chuyển từ sau ra trước
		--	UPDATE [dbo].[SurveyPage]
		--	SET [Index] = [Index]+1 
		--	WHERE [SurveyTableId] = @SurveyTableID
		--		AND [Index] >= @NewIndex AND [Index] <= @OldIndex
		--		AND [ID] <> @ID AND [Status] <> -2;
		--END
		--ELSE
		--BEGIN	--Chuyển từ trước ra sau
		--	UPDATE [dbo].[SurveyPage]
		--	SET [Index] = [Index]-1
		--	WHERE [SurveyTableId] = @SurveyTableID
		--		AND [Index] >= @OldIndex AND [Index] < @NewIndex
		--		AND [ID] <> @ID AND [Status] <> -2;
		--END

		UPDATE  [dbo].[SurveyPage]
		SET [Index] = @NewIndex
		WHERE [ID] = @ID;

		UPDATE tbQuestion
		SET tbQuestion.[Index] = tbQuestion.NewIndex
		FROM (SELECT [SurveyQuestion].[Index], ROW_NUMBER() OVER (ORDER BY [SurveyPage].[Index],[SurveyQuestion].[Index]) AS NewIndex
				FROM [dbo].[SurveyQuestion]
				LEFT JOIN [dbo].[SurveyPage] ON [SurveyQuestion].[SurveyPageId] =[SurveyPage].[ID]
				WHERE  [SurveyPage].[Status] <> -2
					AND [SurveyQuestion].[Status]<>-2
					AND [SurveyQuestion].[SurveyTableId] = @SurveyTableID) tbQuestion

		SELECT * FROM [dbo].[SurveyPage]
		WHERE [SurveyTableId] = @SurveyTableID AND [Status] <> -2
		ORDER BY [Index];

		SELECT * FROM [dbo].[SurveyQuestion] 
		WHERE [SurveyQuestion].[SurveyTableId] = @SurveyTableID AND [SurveyQuestion].[Status] <> -2
		ORDER BY [SurveyQuestion].[Index]

		DECLARE @tbDanhSachXoaReNhanh TABLE
			(ID uniqueidentifier);

		INSERT INTO @tbDanhSachXoaReNhanh (ID)
		SELECT DISTINCT([SurveyBranching].[ID]) FROM [dbo].[SurveyQuestion]
		INNER JOIN [dbo].[SurveyBranching] ON ( [SurveyQuestion].[ID] = [SurveyBranching].SurveyQuestionId OR [SurveyQuestion].[ID] =[SurveyBranching].[JumpToSurveyQuestionId] OR [SurveyBranching].[RefSQId] = [SurveyQuestion].[ID])
		WHERE [SurveyQuestion].[SurveyPageId] = @ID;

		INSERT INTO @tbDanhSachXoaReNhanh (ID)
		SELECT DISTINCT [SurveyBranching].[ID] FROM  [dbo].[SurveyBranching]
		WHERE [SurveyBranching].ParentId IN (SELECT [ID] FROM @tbDanhSachXoaReNhanh)
		AND NOT EXISTS (SELECT TB2.[ID] FROM @tbDanhSachXoaReNhanh TB2 WHERE TB2.[ID] = [SurveyBranching].[ID])

		DECLARE @tbDanhSachRelation TABLE(ID uniqueidentifier);

		INSERT INTO @tbDanhSachRelation
		SELECT [ID] FROM [dbo].[SurveyQuestionRelations]
		WHERE [SurveyBranchingId] IN (SELECT [ID] FROM @tbDanhSachXoaReNhanh )

		SELECT * FROM @tbDanhSachXoaReNhanh;

		SELECT * FROM @tbDanhSachRelation;

		DELETE FROM [dbo].[SurveyBranching]
		WHERE [ID] IN (SELECT [ID] FROM @tbDanhSachXoaReNhanh)

		DELETE FROM [dbo].[SurveyQuestionRelations]
		WHERE [ID] IN (SELECT [ID] FROM @tbDanhSachRelation)

		COMMIT;
		RETURN 1;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		RETURN 0;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyPage_MovePage_bk]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyPage_MovePage_bk]
	@ID uniqueidentifier,
	@Index int,
	@ModifiedBy uniqueidentifier
AS
BEGIN
BEGIN TRAN
	BEGIN TRY
		DECLARE @ErrorMessage nvarchar(1000);
		DECLARE @SurveyTableID uniqueidentifier;
		DECLARE @OldIndex int;

		--Tìm Index cũ và SurveyTableID
		SELECT @OldIndex  = [Index],@SurveyTableID = [SurveyTableId]
		FROM [dbo].[SurveyPage]
		WHERE [ID] = @ID;

		IF(@OldIndex IS NULL OR @Index < @OldIndex)
		BEGIN	-- Chuyển từ sau ra trước
			UPDATE [dbo].[SurveyPage]
			SET [Index] = [Index]+1 
			WHERE [SurveyTableId] = @SurveyTableID
				AND [Index] >= @Index AND [Index] <= @OldIndex
				AND [ID] <> @ID;
		END
		ELSE
		BEGIN	--Chuyển từ trước ra sau
			UPDATE [dbo].[SurveyPage]
			SET [Index] = [Index]-1
			WHERE [SurveyTableId] = @SurveyTableID
				AND [Index] >= @OldIndex AND [Index] <= @Index
				AND [ID] <> @ID;
		END

		UPDATE  [dbo].[SurveyPage]
		SET [Index] = @Index
		WHERE [ID] = @ID;

		UPDATE tbQuestion
		SET tbQuestion.[Index] = tbQuestion.NewIndex
		FROM (SELECT [SurveyQuestion].[Index], ROW_NUMBER() OVER (ORDER BY [SurveyPage].[Index],[SurveyQuestion].[Index]) AS NewIndex
				FROM [dbo].[SurveyQuestion]
				LEFT JOIN [dbo].[SurveyPage] ON [SurveyQuestion].[SurveyPageId] =[SurveyPage].[ID]
				WHERE  [SurveyPage].[Status] <> -2
					AND [SurveyQuestion].[Status]<>-2
					AND [SurveyQuestion].[SurveyTableId] = @SurveyTableID) tbQuestion

		SELECT * FROM [dbo].[SurveyPage]
		WHERE [SurveyTableId] = @SurveyTableID AND [Status] <> -2
		ORDER BY [Index];

		SELECT * FROM [dbo].[SurveyQuestion] 
		WHERE [SurveyQuestion].[SurveyTableId] = @SurveyTableID AND [SurveyQuestion].[Status] <> -2
		ORDER BY [SurveyQuestion].[Index]
		COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyPage_Select]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyPage_Select]
	@ID uniqueidentifier = null,
	@SurveyTableId uniqueidentifier = null,
	@Index int = null,
	@Status int =1,
	@LoaiSelect int = 0 ----- 0 : ALL, 1 : >, 2 : >=, -1 : <. -2 : <=
AS
BEGIN
	SELECT *
	FROM [dbo].[SurveyPage]
	WHERE (@ID IS NULL OR [ID] = @ID)
	AND (@SurveyTableId IS NULL OR [SurveyTableId] = @SurveyTableId)
	AND (@Status IS NULL OR [Status] = @Status)
	AND (@Index IS NULL 
		OR (@LoaiSelect = 0 AND [Index] = @Index)
		OR (@LoaiSelect = 1 AND [Index] > @Index)
		OR (@LoaiSelect = 2 AND [Index] >= @Index)
		OR (@LoaiSelect = -1 AND [Index] < @Index)
		OR (@LoaiSelect = -2 AND [Index] <= @Index))
	ORDER BY [Index] ASC
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyPage_Select_BySurveyTable]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyPage_Select_BySurveyTable]
	@SurveyTableId uniqueidentifier,
	@Index int,
	@Status int =1
AS
BEGIN
	SELECT *
	FROM [dbo].[SurveyPage]
	WHERE ([SurveyTableId] = @SurveyTableId)
	AND (@Index IS NULL OR [Index] = @Index)
	AND (@Status IS NULL OR [Status] = @Status)
	ORDER BY [Index] ASC
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyPermission_Delete]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--delete from SurveyPermission

CREATE PROC [dbo].[vuthao_Survey_SurveyPermission_Delete]
@SurveyTableId varchar(100)
AS
BEGIN
	Delete SurveyPermission where SurveyTableId = @SurveyTableId
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyQuestion_AddQuestionFromMultipleTemplate]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyQuestion_AddQuestionFromMultipleTemplate]
	@ArrayTemplateId varchar(max),
	@SurveyTableId uniqueidentifier = null,
	@SurveyPageId uniqueidentifier = null,
	@UserId uniqueidentifier = null,
	@IsReturnData bit = 1
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		DECLARE @ErrorMessage NVARCHAR(1000);
		DECLARE	@return_value int;
		
		Declare cTemplate Cursor for select [Item] from [dbo].[Split](@ArrayTemplateId,'|') as ListTemplateId
		Open cTemplate
		Declare @ID nvarchar(max);
		Fetch next From cTemplate into @ID
		While @@Fetch_Status=0
		BEGIN
			DECLARE @Uid UNIQUEIDENTIFIER = CAST(@ID as UNIQUEIDENTIFIER);

			EXEC	@return_value = [dbo].[vuthao_Survey_SurveyQuestion_AddQuestionFromSingleTemplate]
					@ID = @Uid ,
					@SurveyTableId = @SurveyTableId,
					@SurveyPageId = @SurveyPageId,
					@UserId = @UserId,
					@IsReturnData = 0

			IF(@return_value = 0)
			BEGIN
				SELECT @ErrorMessage = 'Template bi loi : ' + @ID;
				RAISERROR(@ErrorMessage, 16, 1)
				RETURN 0;
			END
			Fetch next From cTemplate into @ID
		END
		CLOSE cTemplate;
		Deallocate cTemplate;

		IF(@IsReturnData = 1)
		BEGIN
			-- Trả về danh sách câu hỏi mới
			SELECT * FROM SurveyQuestion where SurveyTableId = @SurveyTableId and [Status] <> -2 order by [Index] asc
		END

		COMMIT
		RETURN 1;
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT @ErrorMessage = 'Error : ' + ERROR_MESSAGE()
		RAISERROR(@ErrorMessage, 16, 1)
		RETURN 0;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyQuestion_AddQuestionFromSingleTemplate]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyQuestion_AddQuestionFromSingleTemplate]
	@ID uniqueidentifier,
	@SurveyTableId uniqueidentifier = null,
	@SurveyPageId uniqueidentifier = null,
	@UserId uniqueidentifier = null,
	@IsReturnData bit = 1
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		DECLARE @ErrorMessage NVARCHAR(1000);
		
		IF(@ID IS NULL OR NOT EXISTS(SELECT ID FROM SurveyQuestionTemplate WHERE [ID] = @ID))
		BEGIN
			COMMIT;
			RETURN 0;
		END

		DECLARE @cType int;DECLARE @Title NVARCHAR(4000);DECLARE @DisableDoAgain BIT;
		DECLARE @Description nvarchar(max);DECLARE @Value nvarchar(max);DECLARE @Status tinyint = 1;DECLARE @Required bit = 0;DECLARE @Formula nvarchar(2000) = null;DECLARE @FormulaMessage nvarchar(2000) = null;DECLARE @Options nvarchar(max) = null;

		SELECT @cType = [SQTId],@Title=[Title],@Description=[Description],@Value=[Value],@Required=[Required],@Formula=[Formula],@FormulaMessage=[FormulaMessage],@Options=[Options],@DisableDoAgain = [DisableDoAgain]
		FROM [dbo].[SurveyQuestionTemplate]
		WHERE [SurveyQuestionTemplate].[ID] = @ID;

		DECLARE @ReturnVal int; DECLARE @ReturnID UNIQUEIDENTIFIER = NULL;
		exec @ReturnVal =  vuthao_Survey_SurveyQuestion_Insert @Type=@cType,@SurveyTableId = @SurveyTableId,@SurveyPageId =@SurveyPageId ,@Title=@Title,@Description=@Description
		,@Value = @Value,@Status = @Status,@Required = @Required,@Formula = @Formula,@FormulaMessage = @FormulaMessage,@Options = @Options
		,@CreatedBy = @UserId,@DisableDoAgain = @DisableDoAgain,@IsReturnData = 0, @ReturnID = @ReturnID

		IF(@ReturnVal = 0)
		BEGIN
			ROLLBACK
			RETURN @ReturnVal;
		END

		IF(@IsReturnData = 1)
		BEGIN
			-- Trả về danh sách câu hỏi mới
			SELECT * FROM SurveyQuestion where SurveyTableId = @SurveyTableId and [Status] <> -2 order by [Index] asc

			SELECT 'NEWQUESTION' = @ReturnID
		END

		COMMIT
		RETURN 1;
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT @ErrorMessage = 'Error : ' + ERROR_MESSAGE()
		RAISERROR(@ErrorMessage, 16, 1)
		RETURN 0;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyQuestion_Delete]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyQuestion_Delete]
	@ID uniqueidentifier
AS
BEGIN
BEGIN TRAN
	BEGIN TRY
		DECLARE @ErrorMessage VARCHAR(2000);
		DECLARE @SurveyTableId uniqueidentifier; DECLARE @DeletedIndex int;
		-- Tìm ID bảng khảo sát, và ID của page bị xóa
		SELECT @SurveyTableId = [SurveyTableId],@DeletedIndex = [Index]
		FROM [dbo].[SurveyQuestion]
		WHERE [ID] = @ID;

		-- Deactive câu hỏi 
		UPDATE [dbo].[SurveyQuestion]
		SET [Status] = -2
		WHERE [ID] = @ID;

		---- Set lại Index các câu trong Survey
		--UPDATE [dbo].[SurveyQuestion]
		--		SET [SurveyQuestion].[Index] = newSQ.NewIndex
		--		FROM (
		--			SELECT ROW_NUMBER() OVER(ORDER BY tempSQ.[Index] ASC) AS NewIndex,	tempSQ.*
		--			FROM [dbo].[SurveyQuestion] tempSQ
		--			WHERE tempSQ.[SurveyTableId] = @SurveyTableId AND tempSQ.[Status] IN (0,1)
		--		) newSQ
		--		WHERE [SurveyQuestion].[ID] = newSQ.ID


		-- Trả về danh sach Rẽ nhánh ID bị xóa (Xóa cả nhánh con)
		DECLARE @tbDanhSachXoaReNhanh TABLE
			(ID uniqueidentifier);
		INSERT INTO @tbDanhSachXoaReNhanh (ID)
		SELECT DISTINCT [ID] FROM [dbo].[SurveyBranching]
		WHERE([SurveyBranching].[SurveyQuestionId] = @ID) OR ([JumpToSurveyQuestionId] = @ID) OR ([SurveyBranching].[RefSQId] = @ID)
		
		INSERT INTO @tbDanhSachXoaReNhanh (ID)
		SELECT DISTINCT [SurveyBranching].[ID] FROM  [dbo].[SurveyBranching]
		WHERE [SurveyBranching].ParentId IN (SELECT [ID] FROM @tbDanhSachXoaReNhanh)
		--AND NOT EXISTS (SELECT TB2.[ID] FROM @tbDanhSachXoaReNhanh TB2 WHERE TB2.[ID] = [SurveyBranching].[ID])


		DECLARE @tbDanhSachRelation TABLE(ID uniqueidentifier);

		INSERT INTO @tbDanhSachRelation
		SELECT [ID] FROM [dbo].[SurveyQuestionRelations]
		WHERE [SurveyBranchingId] IN (SELECT [ID] FROM @tbDanhSachXoaReNhanh )

		SELECT * FROM @tbDanhSachXoaReNhanh;

		SELECT * FROM @tbDanhSachRelation;

		DELETE FROM [dbo].[SurveyBranching]
		WHERE [ID] IN (SELECT [ID] FROM @tbDanhSachXoaReNhanh)

		DELETE FROM [dbo].[SurveyQuestionRelations]
		WHERE [ID] IN (SELECT [ID] FROM @tbDanhSachRelation)

		COMMIT
		RETURN 1;
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT @ErrorMessage = 'Error : ' + ERROR_MESSAGE()
		RAISERROR(@ErrorMessage, 16, 1)
		RETURN 0;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyQuestion_GetBySurveyTableId]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyQuestion_GetBySurveyTableId]
	@SurveyTableId uniqueidentifier = null,
	@Status tinyint = null ,  /* -2 deactive, 0 draft, 1 active, 2 : draft va` active */
	@Index int = null
AS
BEGIN
	SELECT *
	FROM [dbo].[SurveyQuestion]
	WHERE [SurveyTableId] = @SurveyTableId
	AND (@Status is null or (@Status = 2 and [Status] in (0,1)) or [Status] = @Status)
	AND (@Index is null or [Index] = @Index)
	ORDER BY [Index] ASC
END

GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyQuestion_Insert]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyQuestion_Insert]
	@Type int,
	@SurveyTableId uniqueidentifier = null,
	@SurveyPageId uniqueidentifier = null,
	@SurveyGroupId uniqueidentifier = null,
	@Title nvarchar(4000),
	@Description nvarchar(max) = null,
	@Value nvarchar(max) = null,
	@Status tinyint = 1,
	@Required bit = 0,
	@Formula nvarchar(2000) = null,
	@FormulaMessage nvarchar(2000) = null,
	--@Index int,
	@CreatedBy uniqueidentifier = null,
	@Options nvarchar(max) = null,
	@DisableDoAgain bit = 0,
	@IsScoring bit = 0,
	@ValidValue nvarchar(max)=null,
	@Score smallint=null,
	@Position varchar(8) = 'after',
	@QuestionId uniqueidentifier = null,
	@IsReturnData bit = 1,		-- Có trả về dữ liệu không
	@ReturnID uniqueidentifier OUTPUT
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		DECLARE @ErrorMessage NVARCHAR(1000);
		DECLARE @Created DATETIME = GETDATE();
		DECLARE @ID uniqueidentifier = NEWID();

		DECLARE @NewIndex int;
		IF(@SurveyPageId IS NULL AND @SurveyTableId IS NULL)
		BEGIN
			SELECT @ErrorMessage = 'DU LIEU TRUYEN VAO KHONG DUNG';
			RAISERROR(@ErrorMessage, 16, 1)
		END

		IF(@SurveyPageId IS NOT NULL)
		BEGIN
			SET @SurveyTableId = (SELECT TOP 1 [SurveyTableId] FROM [dbo].[SurveyPage] WHERE [ID] = @SurveyPageId);
			IF(@SurveyTableId IS NULL)
			BEGIN
				SELECT @ErrorMessage = 'KHONG TIM THAY BANG KHAO SAT';
				RAISERROR(@ErrorMessage, 16, 1)
			END
		END
		ELSE
		BEGIN
			IF(@SurveyTableId IS NOT NULL)
			BEGIN
				SET @SurveyPageId = (SELECT TOP 1 [ID] FROM [dbo].[SurveyPage] WHERE [SurveyTableId] = @SurveyTableId and [Status] <> -2 ORDER BY [Index] DESC );
				IF(@SurveyPageId IS NULL)
				BEGIN
					SELECT @ErrorMessage = 'KHONG TIM THAY TRANG KHAO SAT';
					RAISERROR(@ErrorMessage, 16, 1)
				END
			END
		END
		
		-- Tính index mới 
		IF (@QuestionId is null)
		BEGIN
			DECLARE @MaxIndexInNewPage int = 0;
			SET @MaxIndexInNewPage = (SELECT TOP 1 MAX([Index]) from SurveyQuestion where SurveyTableId = @SurveyTableId AND SurveyPageId = @SurveyPageId)

			IF(@MaxIndexInNewPage IS NULL OR @MaxIndexInNewPage = 0)
			BEGIN
				DECLARE @NewPageIndex int;
				SELECT @NewPageIndex = [Index] from SurveyPage where ID = @SurveyPageId;

				DECLARE @BeforPageId uniqueidentifier = null;
				SELECT @BeforPageId = (SELECT TOP 1 ID FROM SurveyPage WHERE [SurveyTableId] = @SurveyTableId AND [Index] < @NewPageIndex ORDER BY [Index] desc)

				IF(@BeforPageId is null)
					SET @NewIndex = 1;
				ELSE
					SET @NewIndex = (SELECT TOP 1 [Index] + 1 from SurveyQuestion where  [SurveyTableId] = @SurveyTableId AND SurveyPageId = @BeforPageId ORDER BY [Index] desc)
			END
			ELSE
			BEGIN
				SET @NewIndex = @MaxIndexInNewPage + 1
			END
		END
		ELSE
		BEGIN
			SET @NewIndex = (SELECT TOP 1 [Index] from SurveyQuestion where ID = @QuestionId order by [Index] desc)

			IF(@Position = 'after')
				SET @NewIndex = @NewIndex +1;
		END
		
		-- Set Option mặc định
		IF(@Options IS NULL)
		BEGIN
			SELECT @Options = [DefaultOptions]
			FROM [dbo].[SurveyQuestionType]
			WHERE [ID] = @Type
		END
		-- Set Status mặc định
		if(@Status is null OR @Status <> -2 )
		begin
			set @Status = 1;
		end

		-- Cập nhật lại index của các câu hỏi tại index mới thêm trở về sau
		UPDATE [dbo].[SurveyQuestion]
		SET [Index] = [Index]+1
		WHERE [SurveyTableId] = @SurveyTableId AND [Index] >= @NewIndex

		-- Insert câu hỏi mới
		INSERT INTO [dbo].[SurveyQuestion] ([ID],[SQTId],[SurveyTableId],[SurveyGroupId],[SurveyPageId],
		[Title],[Description],[Value],[Status],[Required],[Formula],[FormulaMessage],[Index],
		[Modified],[ModifiedBy],[Created],[CreatedBy],[Options],[DisableDoAgain],[IsScoring],[ValidValue],[Score])
		 VALUES
		(@ID,@Type,@SurveyTableId,@SurveyGroupId,@SurveyPageId,@Title,@Description,@Value,@Status,@Required,@Formula,@FormulaMessage,
		@NewIndex,@Created,@CreatedBy,@Created,@CreatedBy,@Options,@DisableDoAgain,@IsScoring,@ValidValue,@Score)

		IF(@IsReturnData = 1)
		BEGIN
		-- Trả về danh sách câu hỏi mới
		SELECT * FROM SurveyQuestion where SurveyTableId = @SurveyTableId and [Status] <> -2 order by [Index] asc

		SET @ReturnID = @ID;
		END
		
		COMMIT
		RETURN 1;
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT @ErrorMessage = 'Error : ' + ERROR_MESSAGE()
		RAISERROR(@ErrorMessage, 16, 1)
		RETURN 0;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyQuestion_MoveQuestion]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyQuestion_MoveQuestion]
	@ID uniqueidentifier,
	@SurveyPageId uniqueidentifier,
	@Position varchar(8),
	@QuestionId uniqueidentifier,
	--@Index int,
	@ModifiedBy uniqueidentifier
AS
BEGIN
BEGIN TRAN
	BEGIN TRY
		DECLARE @ErrorMessage nvarchar(1000);
		if NOT EXISTS (SELECT * FROM [dbo].[SurveyQuestion] WHERE [ID] = @ID)
		BEGIN
			SELECT @ErrorMessage = 'KHONG TIM THAY CAU HOI KHAO SAT';
			RAISERROR(@ErrorMessage, 16, 1)
		END

		DECLARE @SurveyTableId uniqueidentifier;DECLARE @OldIndex int; DECLARE @NewIndex int;
		SELECT TOP 1 @SurveyTableId = [SurveyTableId],@OldIndex = [Index] FROM [dbo].[SurveyQuestion] WHERE [ID] = @ID

		-- Tính index mới 
		IF (@QuestionId is null)
		BEGIN
			DECLARE @NewPageIndex int;
			SELECT @NewPageIndex = [Index] from SurveyPage where ID = @SurveyPageId;

			DECLARE @BeforPageId uniqueidentifier = null;
			SELECT @BeforPageId = (SELECT TOP 1 ID FROM SurveyPage WHERE [SurveyTableId] = @SurveyTableId AND [Index] < @NewPageIndex AND [Status] <> -2 ORDER BY [Index] desc)

			IF(@BeforPageId is null)
				SET @NewIndex = 1;
			ELSE
				SET @NewIndex = (SELECT TOP 1 [Index] + 1 from SurveyQuestion where  [SurveyTableId] = @SurveyTableId AND SurveyPageId = @BeforPageId AND [Status] <> -2 ORDER BY [Index] desc)
		END
		ELSE
		BEGIN
			SET @NewIndex = (SELECT TOP 1 [Index] from SurveyQuestion where ID = @QuestionId order by [Index] desc)

			IF(@Position = 'after' )
				SET @NewIndex = @NewIndex +1;
			
			--IF(@Position <> 'after' AND @OldIndex <= @NewIndex)
			--	SET @NewIndex = @NewIndex -1;
		END

		UPDATE [dbo].[SurveyQuestion]
		SET [Index] = [Index]+1
		WHERE [SurveyTableId] = @SurveyTableId AND [Status] <> -2	AND [Index] >= @NewIndex 

		--IF(@OldIndex IS NULL OR @NewIndex < @OldIndex)
		--	BEGIN
		--		-- UPDATE Tất cả các câu hỏi có index lớn hơn hoặc bằng index mới (chuyển từ cấu sau ra câu trước)
		--		UPDATE [dbo].[SurveyQuestion]
		--		SET [Index] = [Index]+1
		--		WHERE [SurveyTableId] = @SurveyTableId
		--		AND [Index] >= @NewIndex AND (@OldIndex IS NULL OR [Index] <=@OldIndex)
		--		AND [ID] <> @ID
		--	END
		--ELSE
		--	BEGIN
		--		-- UPDATE Tất cả các câu hỏi có index nhỏ hơn hoặc bằng index mới (chuyển từ câu trước ra câu sau)
		--		UPDATE [dbo].[SurveyQuestion]
		--		SET [Index] = [Index] - 1
		--		WHERE [SurveyTableId] = @SurveyTableId
		--		AND [Index] < @NewIndex AND [Index] >=@OldIndex
		--		AND [ID] <> @ID
		--	END

		UPDATE [dbo].[SurveyQuestion]
		SET [Index] = @NewIndex, [SurveyPageId] = @SurveyPageId,[ModifiedBy] = @ModifiedBy
		WHERE [ID] =@ID

		
		-- Trả về danh sách Question (tất cả)
		SELECT * FROM SurveyQuestion where SurveyTableId = @SurveyTableId and [Status] <> -2 order by [Index] asc

		-- Trả về danh sach Rẽ nhánh ID bị xóa (Xóa cả nhánh con)
		DECLARE @tbDanhSachXoaReNhanh TABLE
			(ID uniqueidentifier);
		INSERT INTO @tbDanhSachXoaReNhanh (ID)
		SELECT DISTINCT [ID] FROM [dbo].[SurveyBranching]
		WHERE([SurveyBranching].[SurveyQuestionId] = @ID) OR ([JumpToSurveyQuestionId] = @ID) OR ([RefSQId] = @ID)
		
		INSERT INTO @tbDanhSachXoaReNhanh (ID)
		SELECT DISTINCT [SurveyBranching].[ID] FROM  [dbo].[SurveyBranching]
		WHERE [SurveyBranching].ParentId IN (SELECT [ID] FROM @tbDanhSachXoaReNhanh)
		--AND NOT EXISTS (SELECT TB2.[ID] FROM @tbDanhSachXoaReNhanh TB2 WHERE TB2.[ID] = [SurveyBranching].[ID])


		DECLARE @tbDanhSachRelation TABLE(ID uniqueidentifier);

		INSERT INTO @tbDanhSachRelation
		SELECT [ID] FROM [dbo].[SurveyQuestionRelations]
		WHERE [SurveyBranchingId] IN (SELECT [ID] FROM @tbDanhSachXoaReNhanh )

		SELECT * FROM @tbDanhSachXoaReNhanh;

		SELECT * FROM @tbDanhSachRelation;

		DELETE FROM [dbo].[SurveyBranching]
		WHERE [ID] IN (SELECT [ID] FROM @tbDanhSachXoaReNhanh)

		DELETE FROM [dbo].[SurveyQuestionRelations]
		WHERE [ID] IN (SELECT [ID] FROM @tbDanhSachRelation)

		COMMIT
		RETURN 1;	
	END TRY
	BEGIN CATCH
		ROLLBACK;
		SELECT @ErrorMessage = ERROR_MESSAGE();
		RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END CATCH	
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyQuestion_SelecById]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyQuestion_SelecById]
	@ID uniqueidentifier
AS
BEGIN
SELECT * FROM SurveyQuestion
where id=@ID
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyQuestion_Select]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyQuestion_Select]
	@ID uniqueidentifier,
	@SurveyTableId uniqueidentifier,
	@SurveyGroupId uniqueidentifier,
	@SurveyPageID uniqueidentifier,
	@Status tinyint,
	@Index int,
	@ArrayQuestionID varchar(max) = null
AS
BEGIN
	IF(@ArrayQuestionID IS NULL OR @ArrayQuestionID='')
	BEGIN
		SELECT *
		FROM [dbo].[SurveyQuestion]
		WHERE  (@ID is null or [ID] = @ID)
		AND (@SurveyTableId is null or [SurveyTableId] = @SurveyTableId)
		AND (@SurveyGroupId is null or [SurveyGroupId] = @SurveyGroupId)
		AND (@SurveyPageID is null or [SurveyPageId] = @SurveyPageID) 
		AND (@Status is null or [Status] = @Status)
		AND (@Index is null or [Index] = @Index)
		ORDER BY [Index] ASC
	END
	ELSE
	BEGIN
		SELECT *
		FROM [dbo].[SurveyQuestion]
		INNER JOIN [dbo].[Split](@ArrayQuestionID,'|') ListQuestionID ON [SurveyQuestion].[ID] = CAST(ListQuestionID.Item as UNIQUEIDENTIFIER)
		WHERE  (@ID is null or [ID] = @ID)
		AND (@SurveyTableId is null or [SurveyTableId] = @SurveyTableId)
		AND (@SurveyGroupId is null or [SurveyGroupId] = @SurveyGroupId)
		AND (@SurveyPageID is null or [SurveyPageId] = @SurveyPageID) 
		AND (@Status is null or [Status] = @Status)
		AND (@Index is null or [Index] = @Index)
		ORDER BY [Index] ASC
	END
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyQuestionTemplate_AddToQuestionBank]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyQuestionTemplate_AddToQuestionBank]
	@QuestionId uniqueidentifier = null,
	@CategoryId int = null,
	@UserId uniqueidentifier = null
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		IF(@QuestionId IS NULL OR @CategoryId IS NULL OR @CategoryId<=0 OR
		  (NOT EXISTS (SELECT [ID] FROM SurveyQuestion WHERE [ID] = @QuestionId)) OR 
		  (NOT EXISTS (SELECT [ID] FROM SurveyCategory WHERE [ID] = @CategoryId)))
		BEGIN
			COMMIT;
			RETURN 0;
		END

		INSERT [dbo].[SurveyQuestionTemplate]([ID],[SQTId],[SCId],[Title],[Description],[Value],[Required],[Formula],[FormulaMessage],[Index],[Options],[DisableDoAgain],[ModifiedBy],[CreatedBy])
		SELECT NEWID() AS ID,[SQTId],@CategoryId,[Title],[Description],[Value],[Required],[Formula],[FormulaMessage],[Index],[Options],[DisableDoAgain],@UserId,@UserId
		FROM [dbo].[SurveyQuestion]
		WHERE [SurveyQuestion].[ID] = @QuestionId

		COMMIT
		RETURN 1;
	END TRY
	BEGIN CATCH
		ROLLBACK
		RETURN 0;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyQuestionTemplate_Select]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyQuestionTemplate_Select]
	@SQTId int = null,
	@SCId int = null,
	@Title nvarchar(4000) = null,
	@Limit int = -1,	-- Số lượng lấy tối đa mỗi lần truy xuất
	@Offset int = 0		-- Vị trí bắt đầu lấy Data
AS
BEGIN
	IF(@Limit < 1)
	BEGIN
		SELECT [SurveyQuestionTemplate].* , [SurveyCategory].Title as Category,[SurveyQuestionType].[Title] AS [Type]
		FROM [dbo].[SurveyQuestionTemplate]
		LEFT JOIN [dbo].[SurveyCategory] ON [SurveyCategory].[ID] = [SurveyQuestionTemplate].[SCId]
		LEFT JOIN [dbo].[SurveyQuestionType] ON [SurveyQuestionType].[ID] = [SurveyQuestionTemplate].[SQTId]
		WHERE (@SQTId IS NULL OR @SQTId = 0 OR  [SQTId] = @SQTId)
		AND (@SCId IS NULL OR @SCId = 0 OR [SCId] = @SCId)
		AND (@Title IS NULL OR  [SurveyQuestionTemplate].[Title] LIKE ('%' + @Title + '%'))
		ORDER BY [Created] DESC
	END
	ELSE
	BEGIN
		SELECT [SurveyQuestionTemplate].* , [SurveyCategory].Title as Category,[SurveyQuestionType].[Title] AS [Type]
		FROM [dbo].[SurveyQuestionTemplate]
		LEFT JOIN [dbo].[SurveyCategory] ON [SurveyCategory].[ID] = [SurveyQuestionTemplate].[SCId]
		LEFT JOIN [dbo].[SurveyQuestionType] ON [SurveyQuestionType].[ID] = [SurveyQuestionTemplate].[SQTId]
		WHERE (@SQTId IS NULL OR @SQTId = 0 OR  [SQTId] = @SQTId)
		AND (@SCId IS NULL OR @SCId = 0 OR [SCId] = @SCId)
		AND (@Title IS NULL OR  [SurveyQuestionTemplate].[Title] LIKE ('%' + @Title + '%'))
		ORDER BY [Created] DESC
		OFFSET @Offset ROWS
		FETCH NEXT @Limit ROWS ONLY
	END
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyQuestionType_Select]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyQuestionType_Select]
	@ID int,
	@Title nvarchar(255),
	@Description nvarchar(255),
	@Status tinyint,
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	SELECT *
	FROM [dbo].[SurveyQuestionType]
	WHERE	(@ID IS NULL OR [ID] = @ID)
	AND (@Title IS NULL OR [Title] LIKE '%'+@Title+'%')
	AND (@Description IS NULL OR [Description] LIKE '%'+@Description+'%')
	AND (@Status IS NULL OR [Status] = @Status)
	AND (@StartDate IS NULL OR [Modified]>=@StartDate OR [Created] >=@StartDate)
	AND (@EndDate IS NULL OR [Modified]<@EndDate OR  [Created]<@EndDate )
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyResponses_Completed]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyResponses_Completed]
	@ID uniqueidentifier			= null,
	@UserId uniqueidentifier		= null,
	@SurveyTableId uniqueidentifier = null,
	@Status tinyint					= 2,/*Ki?m tra n?u Status = 2: L?y all*/
	@NetIPClient varchar(20)		= null,
	@UserName  nvarchar(100) = null,
	@UserEmail nvarchar(250) = null,
	@StaffID nvarchar(250) = null,
	@UserDepartmentID numeric(18,0) = null,
	@FromDate datetime = null,
	@ToDate datetime = null,
	@Limit int = -1,	-- Số lượng lấy tối đa mỗi lần truy xuất
	@Offset int = 0		-- Vị trí bắt đầu lấy Data
	,@TotalRecord INT=0 OUTPUT
AS
BEGIN

	DECLARE @TbRanking as TABLE(
		ID uniqueidentifier,
		Ranking smallint)
	INSERT INTO @TbRanking
	SELECT A.ID, ROW_NUMBER() OVER(ORDER BY A.Score DESC, DATEDIFF(MILLISECOND, A.CREATED, A.CompletedDate) ASC)
	FROM [dbo].[SurveyResponses] A WITH (NOLOCK)
	LEFT JOIN [dbo].[PersonalProfile] B WITH (NOLOCK) ON A.UserID = B.ID
	LEFT JOIN [dbo].[SurveyTable] C WITH (NOLOCK) ON A.[SurveyTableId] = C.[ID]
	LEFT JOIN SurveyCategory SC WITH (NOLOCK) ON C.SurveyCategoryId = SC.ID
	WHERE (@SurveyTableId is null or [SurveyTableId] = @SurveyTableId) 
		AND (A.[Status] <> -2 and (@Status is null or @Status = 2 or A.[Status] = @Status))

	IF(@Limit < 1)
	BEGIN
		SELECT B.FullName, A.*,C.Title AS SurveyTitle,C.StartDate,C.DueDate, SC.Title AS CategoryTitle, B.[Email] AS UserEmail, B.[StaffID] AS StaffID,B.[DepartmentTitle] AS UserDepartment, R.Ranking
		FROM [dbo].[SurveyResponses] A
		LEFT JOIN [dbo].[PersonalProfile] B ON A.UserID = B.ID
		LEFT JOIN [dbo].[SurveyTable] C ON A.[SurveyTableId] = C.[ID]
		LEFT JOIN SurveyCategory SC ON C.SurveyCategoryId = SC.ID
		INNER JOIN @TbRanking R ON A.ID=R.ID
		WHERE (@ID is null or A.[ID] = @ID)
		AND (@UserId is null or [UserId] = @UserId)
		AND (@SurveyTableId is null or [SurveyTableId] = @SurveyTableId) 
		AND (@NetIPClient is null or [NetIPClient] = @NetIPClient)
		AND (A.[Status] <> -2 and (@Status is null or @Status = 2 or A.[Status] = @Status))
		-- THÊM NGÀY 31/7/2017
		AND (@UserName IS NULL OR  B.[FullName] LIKE ('%'+@UserName + '%'))
		AND (@StaffID IS NULL OR  B.[StaffID] LIKE ('%'+@StaffID + '%'))
		AND (@UserEmail IS NULL OR B.[Email] LIKE ('%'+@UserEmail + '%'))
		AND (@UserDepartmentID IS NULL OR B.[DepartmentID] = @UserDepartmentID)
		AND (A.[Created] IS NULL OR 
				((@FromDate IS NULL OR CAST(A.[Created] AS DATE)>=@FromDate) AND
				(@ToDate IS NULL OR  CAST(A.[Created] AS DATE)<= @ToDate)))
		ORDER BY A.Score DESC, DATEDIFF(MILLISECOND, A.CREATED, A.CompletedDate) ASC
	END
	ELSE
	BEGIN
		SELECT B.FullName, A.*,C.Title AS SurveyTitle,C.StartDate,C.DueDate, SC.Title AS CategoryTitle, B.[Email] AS UserEmail, B.[StaffID] AS StaffID,B.[DepartmentTitle] AS UserDepartment, R.Ranking
		FROM [dbo].[SurveyResponses] A
		LEFT JOIN [dbo].[PersonalProfile] B ON A.UserID = B.ID
		LEFT JOIN [dbo].[SurveyTable] C ON A.[SurveyTableId] = C.[ID]
		LEFT JOIN SurveyCategory SC ON C.SurveyCategoryId = SC.ID
		INNER JOIN @TbRanking R ON A.ID=R.ID
		WHERE (@ID is null or A.[ID] = @ID)
		AND (@UserId is null or [UserId] = @UserId)
		AND (@SurveyTableId is null or [SurveyTableId] = @SurveyTableId) 
		AND (@NetIPClient is null or [NetIPClient] = @NetIPClient)
		AND (A.[Status] <> -2 and (@Status is null or @Status = 2 or A.[Status] = @Status))
		AND (@UserName IS NULL OR  B.[FullName] LIKE ('%'+@UserName + '%'))
		AND (@StaffID IS NULL OR  B.[StaffID] LIKE ('%'+@StaffID + '%'))
		AND (@UserEmail IS NULL OR B.[Email] LIKE ('%'+@UserEmail + '%'))
		AND (@UserDepartmentID IS NULL OR B.[DepartmentID] = @UserDepartmentID)
		AND (A.[Created] IS NULL OR 
				((@FromDate IS NULL OR CAST(A.[Created] AS DATE)>=@FromDate) AND
				(@ToDate IS NULL OR  CAST(A.[Created] AS DATE)<= @ToDate)))
		ORDER BY A.Score DESC, DATEDIFF(MILLISECOND, A.CREATED, A.CompletedDate) ASC
		OFFSET @Offset ROWS
		FETCH NEXT @Limit ROWS ONLY
	END
	SELECT @TotalRecord= COUNT(*)
		FROM [dbo].[SurveyResponses] A
		LEFT JOIN [dbo].[PersonalProfile] B ON A.UserID = B.ID
		LEFT JOIN [dbo].[SurveyTable] C ON A.[SurveyTableId] = C.[ID]
		LEFT JOIN SurveyCategory SC ON C.SurveyCategoryId = SC.ID
		WHERE (@SurveyTableId is null or [SurveyTableId] = @SurveyTableId) 
		AND (A.[Status] <> -2 and (@Status is null or @Status = 2 or A.[Status] = @Status))
	
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyResponses_Insert]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyResponses_Insert]
	@UserId uniqueidentifier,
	@SurveyTableId uniqueidentifier,
	@Status smallint,
	@NetIPClient varchar(20),
	@CreatedBy uniqueidentifier
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		DECLARE @ErrorMessage VARCHAR(2000);
		DECLARE @Created datetime = GETDATE();
		DECLARE @ID uniqueidentifier;
		SET @ID  = NEWID();
		
		if(@Status is null)
		SET @Status = 0;

		IF NOT EXISTS (SELECT * FROM [dbo].[SurveyTable] WHERE [ID] = @SurveyTableId)
		BEGIN
			SET @ErrorMessage = 'KHONG TIM THAY BANG KHAO SAT';
			RAISERROR(@ErrorMessage, 16, 1)
		END

		INSERT INTO [dbo].[SurveyResponses]([ID],[UserId],[SurveyTableId],[Status],[Modified],[ModifiedBy],[Created],[CreatedBy],[NetIPClient]) VALUES(@ID,@UserId,@SurveyTableId,@Status,@Created,@CreatedBy,@Created,@CreatedBy,@NetIPClient);

		SELECT * FROM [dbo].[SurveyResponses]
		WHERE  [ID] = @ID;
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT @ErrorMessage = 'Error : ' + ERROR_MESSAGE()
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyResponses_Select]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyResponses_Select]
	@ID uniqueidentifier			= null,
	@UserId uniqueidentifier		= null,
	@SurveyTableId uniqueidentifier = null,
	@Status tinyint					= 2,/*Ki?m tra n?u Status = 2: L?y all*/
	@NetIPClient varchar(20)		= null,
	@UserName  nvarchar(100) = null,
	@UserEmail nvarchar(250) = null,
	@StaffID nvarchar(250) = null,
	@UserDepartmentID numeric(18,0) = null,
	@FromDate datetime = null,
	@ToDate datetime = null,
	@Limit int = -1,	-- Số lượng lấy tối đa mỗi lần truy xuất
	@Offset int = 0		-- Vị trí bắt đầu lấy Data
AS
BEGIN
	IF(@Limit < 1)
	BEGIN
		SELECT B.FullName, A.*,C.Title AS SurveyTitle,C.StartDate,C.DueDate, SC.Title AS CategoryTitle, B.[Email] AS UserEmail, B.[StaffID] AS StaffID,B.[DepartmentTitle] AS UserDepartment
		FROM [dbo].[SurveyResponses] A
		LEFT JOIN [dbo].[PersonalProfile] B ON A.UserID = B.ID
		LEFT JOIN [dbo].[SurveyTable] C ON A.[SurveyTableId] = C.[ID]
		LEFT JOIN SurveyCategory SC ON C.SurveyCategoryId = SC.ID
		WHERE (@ID is null or A.[ID] = @ID)
		AND (@UserId is null or [UserId] = @UserId)
		AND (@SurveyTableId is null or [SurveyTableId] = @SurveyTableId) 
		AND (@NetIPClient is null or [NetIPClient] = @NetIPClient)
		AND (A.[Status] <> -2 and (@Status is null or @Status = 2 or A.[Status] = @Status))
		-- THÊM NGÀY 31/7/2017
		AND (@UserName IS NULL OR  B.[FullName] LIKE ('%'+@UserName + '%'))
		AND (@StaffID IS NULL OR  B.[StaffID] LIKE ('%'+@StaffID + '%'))
		AND (@UserEmail IS NULL OR B.[Email] LIKE ('%'+@UserEmail + '%'))
		AND (@UserDepartmentID IS NULL OR B.[DepartmentID] = @UserDepartmentID)
		AND (A.[Created] IS NULL OR 
				((@FromDate IS NULL OR CAST(A.[Created] AS DATE)>=@FromDate) AND
				(@ToDate IS NULL OR  CAST(A.[Created] AS DATE)<= @ToDate)))
		ORDER BY A.Modified desc
	END
	ELSE
	BEGIN
		SELECT B.FullName, A.*,C.Title AS SurveyTitle,C.StartDate,C.DueDate, SC.Title AS CategoryTitle, B.[Email] AS UserEmail, B.[StaffID] AS StaffID,B.[DepartmentTitle] AS UserDepartment
		FROM [dbo].[SurveyResponses] A
		LEFT JOIN [dbo].[PersonalProfile] B ON A.UserID = B.ID
		LEFT JOIN [dbo].[SurveyTable] C ON A.[SurveyTableId] = C.[ID]
		LEFT JOIN SurveyCategory SC ON C.SurveyCategoryId = SC.ID
		WHERE (@ID is null or A.[ID] = @ID)
		AND (@UserId is null or [UserId] = @UserId)
		AND (@SurveyTableId is null or [SurveyTableId] = @SurveyTableId) 
		AND (@NetIPClient is null or [NetIPClient] = @NetIPClient)
		AND (A.[Status] <> -2 and (@Status is null or @Status = 2 or A.[Status] = @Status))
		-- THÊM NGÀY 31/7/2017
		AND (@UserName IS NULL OR  B.[FullName] LIKE ('%'+@UserName + '%'))
		AND (@StaffID IS NULL OR  B.[StaffID] LIKE ('%'+@StaffID + '%'))
		AND (@UserEmail IS NULL OR B.[Email] LIKE ('%'+@UserEmail + '%'))
		AND (@UserDepartmentID IS NULL OR B.[DepartmentID] = @UserDepartmentID)
		AND (A.[Created] IS NULL OR 
				((@FromDate IS NULL OR CAST(A.[Created] AS DATE)>=@FromDate) AND
				(@ToDate IS NULL OR  CAST(A.[Created] AS DATE)<= @ToDate)))
		ORDER BY A.Modified desc
		OFFSET @Offset ROWS
		FETCH NEXT @Limit ROWS ONLY
	END
	
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyResponsesValue_Delete]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Nguyen>
-- Create date: <Create Date,,27.08.2017>
-- Description:	<Description,,Ham xoa' ResposnesValue>
-- =============================================
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyResponsesValue_Delete]
	@ID uniqueidentifier = null,
	@SurveyResponsesId uniqueidentifier = null,
	@SurveyQuestionId uniqueidentifier = null
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		DELETE FROM [dbo].[SurveyResponsesValue]
		WHERE (@ID IS NOT NULL AND [SurveyResponsesValue].[ID] = @ID)
		OR	((@SurveyResponsesId IS NOT NULL AND [SurveyResponsesValue].[SurveyResponsesId] = @SurveyResponsesId) AND
		 ( @SurveyQuestionId IS NOT NULL AND [SurveyResponsesValue].SurveyQuestionId = @SurveyQuestionId  ))

		COMMIT;
		RETURN 1;
	END TRY
	BEGIN CATCH
		ROLLBACK
		RETURN 0;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyResponsesValue_DeleteFromBranching]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyResponsesValue_DeleteFromBranching]
	@IDResponses uniqueidentifier,
	@IDQuestionBranchingFrom uniqueidentifier,
	@IDQuestionBranchingTo uniqueidentifier
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		DECLARE @SurveyTableId uniqueidentifier;
		SELECT @SurveyTableId = [SurveyTableId]
		FROM [dbo].[SurveyResponses]
		WHERE [ID] = @IDResponses;

		DECLARE @IndexQuestionBranchingFrom int;
		DECLARE @IndexQuestionBranchingTo int;

		SELECT @IndexQuestionBranchingFrom= [Index] 
		FROM [dbo].[SurveyQuestion] WHERE [ID] = @IDQuestionBranchingFrom;

		SELECT @IndexQuestionBranchingTo= [Index] 
		FROM [dbo].[SurveyQuestion] WHERE [ID] = @IDQuestionBranchingTo;

		DECLARE @ListQuestionID Table(
			ID uniqueidentifier
			);
		INSERT INTO @ListQuestionID ([ID])
		SELECT [ID] FROM [dbo].[SurveyQuestion]
		WHERE [SurveyTableId] = @SurveyTableId
		AND ([Index] > @IndexQuestionBranchingFrom AND [Index] < @IndexQuestionBranchingTo)

		Declare cQuestion Cursor for select [ID] from @ListQuestionID
		Open cQuestion
		Declare @QIDDeletedResponsesValue uniqueidentifier;
		Fetch next From cQuestion into @QIDDeletedResponsesValue
		While @@Fetch_Status=0
		BEGIN
			DELETE FROM [dbo].[SurveyResponsesValue]
			WHERE [SurveyResponsesId] = @IDResponses
			AND [SurveyQuestionId] = @QIDDeletedResponsesValue;

			Fetch next From cQuestion into @QIDDeletedResponsesValue
		END
		CLOSE cQuestion;
		Deallocate cQuestion;

		COMMIT;
		RETURN 1;
	END TRY
	BEGIN CATCH
		ROLLBACK
		RETURN 0;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyResponsesValue_InsertUpdate]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyResponsesValue_InsertUpdate]
	@SurveyResponsesId uniqueidentifier = null,
	@SurveyQuestionId uniqueidentifier = null,
	@Value nvarchar(max) = null,
	@Skipped bit = 0,
	@CreatedBy uniqueidentifier = null,
	@OtherValue nvarchar(max) = '',
	@Status bit = 0,
	@OriginSkipped bit = 0,
	@CheckLogicJSON nvarchar(max) = '',
	@Score smallint=null
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		DECLARE @ErrorMessage VARCHAR(2000);
		DECLARE @Created datetime = GETDATE();
		DECLARE @ID uniqueidentifier;
		SET @ID  = NEWID();

		IF NOT EXISTS (SELECT * FROM [dbo].[SurveyQuestion] WHERE [ID] = @SurveyQuestionId)
		BEGIN
			SET @ErrorMessage = 'KHONG TIM THAY CAU HOI';
			RAISERROR(@ErrorMessage, 16, 1)
		END

		IF NOT EXISTS (SELECT * FROM [dbo].[SurveyResponses] WHERE [ID] = @SurveyResponsesId)
		BEGIN
			SET @ErrorMessage = 'KHONG TIM THAY BANG DANH GIA';
			RAISERROR(@ErrorMessage, 16, 1)
		END

		IF NOT EXISTS (SELECT * FROM [dbo].[SurveyResponsesValue] 
						WHERE [SurveyResponsesId] = @SurveyResponsesId 
						AND [SurveyQuestionId] = @SurveyQuestionId)
		BEGIN
		-- N?u ch?a có câu tr? l?i trong db
			INSERT INTO [dbo].[SurveyResponsesValue] ([ID],[SurveyResponsesId],[SurveyQuestionId],[Value],[Skipped],[Modified],[ModifiedBy],[Created],[CreatedBy],[OtherValue],[Status],[CheckLogicJSON],[OriginSkipped],[Score])
			VALUES (@ID,@SurveyResponsesId,@SurveyQuestionId,@Value,@Skipped,@Created,@CreatedBy,@Created,@CreatedBy,@OtherValue,@Status,@CheckLogicJSON,@OriginSkipped,@Score);

			SELECT * FROM [dbo].[SurveyResponsesValue] WHERE [ID] = @ID;
		END
		ELSE
		BEGIN -- N?u ?ã có 1 câu tr? l?i trong db
			UPDATE [dbo].[SurveyResponsesValue]
			SET [Value] = @Value,[Skipped] = @Skipped, [Modified] = @Created,[ModifiedBy] = @CreatedBy,[OtherValue] = @OtherValue,[Status] = @Status,[CheckLogicJSON] = @CheckLogicJSON,[OriginSkipped] = @OriginSkipped,[Score]=@Score
			WHERE [SurveyResponsesId] = @SurveyResponsesId AND [SurveyQuestionId] = @SurveyQuestionId;

			SELECT * FROM [dbo].[SurveyResponsesValue]
			WHERE [SurveyResponsesId] = @SurveyResponsesId AND [SurveyQuestionId] = @SurveyQuestionId;
		END
		COMMIT
	END TRY
	BEGIN CATCH
	ROLLBACK
		SELECT @ErrorMessage = 'Error : ' + ERROR_MESSAGE()
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyResponsesValue_Select]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyResponsesValue_Select]
	@ID uniqueidentifier = null,
	@SurveyResponsesId uniqueidentifier = null,
	@SurveyQuestionId uniqueidentifier = null,
	@SurveyTableID uniqueidentifier = null,
	@ArrayResponsesId varchar(max) = null,
	@Status smallint =2, -- 0: Draft , 1 : Completed, 2 : All
	@ArrayQuestionID varchar(max) = null
AS
BEGIN
	IF(@ArrayResponsesId IS NULL OR @ArrayResponsesId='')
	BEGIN
		IF(@ArrayQuestionID IS NULL OR @ArrayQuestionID = '')
		BEGIN
			SELECT [SurveyResponses].SurveyTableId,[SurveyResponsesValue].*,[PersonalProfile].[FullName] AS AuthorName
			FROM [dbo].[SurveyResponsesValue]
			LEFT JOIN [dbo].[SurveyResponses] ON [SurveyResponses].[ID] = [SurveyResponsesValue].[SurveyResponsesId]
			LEFT JOIN [dbo].[PersonalProfile] ON [PersonalProfile].[ID] = [SurveyResponsesValue].[CreatedBy]
			WHERE (@ID IS NULL OR [SurveyResponsesValue].[ID] = @ID)
			AND (@SurveyResponsesId IS NULL OR [SurveyResponsesValue].[SurveyResponsesId] = @SurveyResponsesId)
			AND (@SurveyQuestionId IS NULL OR [SurveyResponsesValue].[SurveyQuestionId] = @SurveyQuestionId)
			AND ([SurveyResponses].[Status] <> -2 AND
					(@Status = 2 OR ([SurveyResponses].[Status] = @Status)))
			AND (@SurveyTableID IS NULL OR [SurveyResponses].[SurveyTableId] = @SurveyTableID)
		END
		ELSE
		BEGIN
			SELECT [SurveyResponses].SurveyTableId, [SurveyResponsesValue].*,[PersonalProfile].[FullName] AS AuthorName
			FROM [dbo].[SurveyResponsesValue]
			LEFT JOIN [dbo].[SurveyResponses] ON [SurveyResponses].[ID] = [SurveyResponsesValue].[SurveyResponsesId]
			LEFT JOIN [dbo].[PersonalProfile] ON [PersonalProfile].[ID] = [SurveyResponsesValue].[CreatedBy]
			INNER JOIN [dbo].[Split](@ArrayQuestionID,'|') ListQuestionID ON [SurveyResponsesValue].[SurveyQuestionId] = CAST(ListQuestionID.Item as UNIQUEIDENTIFIER)
			WHERE (@ID IS NULL OR [SurveyResponsesValue].[ID] = @ID)
			AND (@SurveyResponsesId IS NULL OR [SurveyResponsesValue].[SurveyResponsesId] = @SurveyResponsesId)
			AND (@SurveyQuestionId IS NULL OR [SurveyResponsesValue].[SurveyQuestionId] = @SurveyQuestionId)
			AND ([SurveyResponses].[Status] <> -2 AND
					(@Status = 2 OR ([SurveyResponses].[Status] = @Status)))
			AND (@SurveyTableID IS NULL OR [SurveyResponses].[SurveyTableId] = @SurveyTableID)
		END
		
	END
	ELSE
	BEGIN
		IF(@ArrayQuestionID IS NULL OR @ArrayQuestionID = '')
		BEGIN
			SELECT [SurveyResponses].SurveyTableId, [SurveyResponsesValue].*,[PersonalProfile].[FullName] AS AuthorName
			FROM [dbo].[SurveyResponsesValue]
			LEFT JOIN [dbo].[SurveyResponses] ON [SurveyResponses].[ID] = [SurveyResponsesValue].[SurveyResponsesId]
			LEFT JOIN [dbo].[PersonalProfile] ON [PersonalProfile].[ID] = [SurveyResponsesValue].[CreatedBy]
			INNER JOIN [dbo].[Split](@ArrayResponsesId,'|') ListId ON [SurveyResponsesValue].[SurveyResponsesId] = CAST(ListId.Item as UNIQUEIDENTIFIER)
			WHERE (@ID IS NULL OR [SurveyResponsesValue].[ID] = @ID)
			AND (@SurveyResponsesId IS NULL OR [SurveyResponsesValue].[SurveyResponsesId] = @SurveyResponsesId)
			AND (@SurveyQuestionId IS NULL OR [SurveyResponsesValue].[SurveyQuestionId] = @SurveyQuestionId)
			AND ([SurveyResponses].[Status] <> -2 AND
					(@Status = 2 OR ([SurveyResponses].[Status] = @Status)))
			AND (@SurveyTableID IS NULL OR [SurveyResponses].[SurveyTableId] = @SurveyTableID)
		END
		ELSE
		BEGIN
			SELECT [SurveyResponses].SurveyTableId, [SurveyResponsesValue].*,[PersonalProfile].[FullName] AS AuthorName
			FROM [dbo].[SurveyResponsesValue]
			LEFT JOIN [dbo].[SurveyResponses] ON [SurveyResponses].[ID] = [SurveyResponsesValue].[SurveyResponsesId]
			LEFT JOIN [dbo].[PersonalProfile] ON [PersonalProfile].[ID] = [SurveyResponsesValue].[CreatedBy]
			INNER JOIN [dbo].[Split](@ArrayResponsesId,'|') ListId ON [SurveyResponsesValue].[SurveyResponsesId] = CAST(ListId.Item as UNIQUEIDENTIFIER)
			INNER JOIN [dbo].[Split](@ArrayQuestionID,'|') ListQuestionID ON [SurveyResponsesValue].[SurveyQuestionId] = CAST(ListQuestionID.Item as UNIQUEIDENTIFIER)
			WHERE (@ID IS NULL OR [SurveyResponsesValue].[ID] = @ID)
			AND (@SurveyResponsesId IS NULL OR [SurveyResponsesValue].[SurveyResponsesId] = @SurveyResponsesId)
			AND (@SurveyQuestionId IS NULL OR [SurveyResponsesValue].[SurveyQuestionId] = @SurveyQuestionId)
			AND ([SurveyResponses].[Status] <> -2 AND
					(@Status = 2 OR ([SurveyResponses].[Status] = @Status)))
			AND (@SurveyTableID IS NULL OR [SurveyResponses].[SurveyTableId] = @SurveyTableID)
		END
		
	END
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyTable_CheckUserEvaluation]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SurveyResponses

CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyTable_CheckUserEvaluation]
(
	@SurveyTableId UNIQUEIDENTIFIER,
	@UserId UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @AllowMultipleResponses BIT = NULL
	DECLARE @Status SMALLINT
	DECLARE @StartDate DATE, @DueDate DATE
	DECLARE @CurrentDate DATE = CONVERT(DATE,GETDATE())

	SELECT TOP (1) @AllowMultipleResponses = ST.AllowMultipleResponses,
					@Status = ST.[Status],
					@StartDate = ST.StartDate,
					@DueDate = ST.DueDate
	FROM SurveyTable ST
	WHERE ID = @SurveyTableId
	AND (ST.Permission IS NULL OR ST.Permission = '' OR 
		@UserId IN (SELECT SP.UserId FROM SurveyPermission SP 
		WHERE SP.SurveyTableId = @SurveyTableId))

	-- Tình trạng survey không cho phép đánh giá
	IF(@Status <> 1)
	BEGIN
		RETURN -1
	END	
	-- Have Permission In This
	ELSE IF(@AllowMultipleResponses IS NOT NULL)
	BEGIN	
		IF((@StartDate IS NULL OR @CurrentDate >= @StartDate) AND (@DueDate IS NULL OR @CurrentDate <= @DueDate))
		BEGIN
			DECLARE @ResponsesCount TINYINT = 0
			SET @ResponsesCount = (SELECT COUNT(SR.ID) FROM SurveyResponses SR 
									WHERE SR.SurveyTableId = @SurveyTableId
									AND SR.UserId = @UserId
									AND SR.[Status] = 1)
			IF(@ResponsesCount = 0 OR @AllowMultipleResponses = 1)
				RETURN 1 -- Có quyền, còn lượt đánh giá
			ELSE
				RETURN -2	-- Hết lượt đánh giá
		END
		ELSE IF (@StartDate IS NOT NULL AND @StartDate > @CurrentDate)
		BEGIN
			RETURN -3	-- Chưa đến lượt đánh giá
		END
		ELSE IF (@DueDate IS NOT NULL AND @DueDate < @CurrentDate)
		BEGIN
			RETURN -4	-- Hết hạn đánh giá
		END
	END
	-- Không có quyền đánh giá
	ELSE
	BEGIN
		RETURN 0	
	END
END 
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyTable_CopyPageQuestionBranching]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyTable_CopyPageQuestionBranching]
@SurveyTableFromId uniqueidentifier = null,
@SurveyTableToId uniqueidentifier = null
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		IF(@SurveyTableFromId IS NULL OR @SurveyTableToId IS NULL OR @SurveyTableFromId=@SurveyTableToId) RETURN 0;

		-- Copy các Page
		DECLARE @ClonePageId TABLE(
			IDFrom uniqueidentifier,
			IDTo uniqueidentifier
		);
		INSERT INTO @ClonePageId ([IDFrom],[IDTo])
		SELECT [SurveyPage].[ID] as [IDFrom],NEWID() as [IDTo]
		FROM [dbo].[SurveyPage]
		WHERE [SurveyPage].[SurveyTableId] = @SurveyTableFromId AND [SurveyPage].[Status] <>-2

		--SELECT * FROM @ClonePageId
		
		INSERT INTO [dbo].[SurveyPage] ([ID],[SurveyTableId],[Title],[Status],[Index],[ModifiedBy],[CreatedBy],[Options])
		SELECT (SELECT TOP 1 CPage.[IDTo] FROM @ClonePageId AS CPage WHERE CPage.[IDFrom] = [SurveyPage].[ID]) AS [ID]
		,@SurveyTableToId AS [SurveyTableId],[Title],[Status],[Index],[ModifiedBy],[CreatedBy],[Options]
		FROM [dbo].[SurveyPage]
		WHERE [SurveyPage].[SurveyTableId] = @SurveyTableFromId AND [SurveyPage].[Status] <>-2


		-- Copy các Question
		DECLARE @CloneQuestionId TABLE(
			IDFrom uniqueidentifier,
			IDTo uniqueidentifier
		);
		INSERT INTO @CloneQuestionId(IDFrom,IDTo)
		SELECT ID as IDFrom, NEWID() as IDTo
		FROM [dbo].[SurveyQuestion]
		WHERE [SurveyTableId] = @SurveyTableFromId AND [Status] <>-2
		
		--SELECT * FROM @CloneQuestionId

		INSERT INTO [dbo].[SurveyQuestion]([ID],[SQTId],[SurveyTableId],[SurveyPageId],[Title],[Description],[Value],[Status],[Required],[Formula],[FormulaMessage],[Index],[ModifiedBy],[CreatedBy],[Options],[DisableDoAgain])
		SELECT (SELECT TOP 1 CQuestion.IDTo FROM @CloneQuestionId CQuestion where CQuestion.IDFrom = SQFrom.ID) as ID
			,SQFrom.SQTId,@SurveyTableToId as [SurveyTableId]
			,(SELECT TOP 1 CPage.IDTo FROM @ClonePageId CPage WHERE CPage.IDFrom = SQFrom.[SurveyPageId]) as [SurveyPageId]
			,SQFrom.[Title],SQFrom.[Description],SQFrom.[Value],SQFrom.[Status],SQFrom.[Required],SQFrom.[Formula],SQFrom.[FormulaMessage],SQFrom.[Index],SQFrom.[ModifiedBy],SQFrom.[CreatedBy],SQFrom.[Options],SQFrom.[DisableDoAgain]
		FROM [dbo].[SurveyQuestion] SQFrom
		WHERE SQFrom.[SurveyTableId] = @SurveyTableFromId AND SQFrom.[Status] <>-2

		-- Copy các Branching cha
		DECLARE @CloneBranching TABLE(
			IDFrom uniqueidentifier,
			IDTo uniqueidentifier
		);
		INSERT INTO @CloneBranching(IDFrom,IDTo)
		SELECT SBFROM.ID AS IDFrom, NEWID() AS IDTo
		FROM [dbo].[SurveyBranching] SBFROM
		INNER JOIN [dbo].[SurveyQuestion] SQFROM ON SQFROM.[ID] = SBFROM.[SurveyQuestionId]
		WHERE SQFROM.[Status]<>-2 AND SQFROM.[SurveyTableId] = @SurveyTableFromId

		--SELECT * FROM @CloneBranching

		INSERT INTO [dbo].[SurveyBranching] ([ID],[ParentId],[SurveyQuestionId],[SubQuestionId],[RefSQId],[Value],[Condition],[JumpToSurveyPageId],[JumpToSurveyQuestionId],[Operator],[IsNext],[Index],[Type],[ModifiedBy],[CreatedBy])
		SELECT (SELECT TOP 1 CBranching.IDTo FROM @CloneBranching CBranching WHERE CBranching.IDFrom = SBFROM.ID) as [ID]
		,(SELECT TOP 1 CBranching.IDTo FROM @CloneBranching CBranching WHERE CBranching.IDFrom = SBFROM.ParentId) AS [ParentId]
		,(SELECT TOP 1 CQuestion.IDTo FROM @CloneQuestionId CQuestion WHERE CQuestion.IDFrom = SBFROM.SurveyQuestionId) AS [SurveyQuestionId]
		,(SELECT TOP 1 CQuestion.IDTo FROM @CloneQuestionId CQuestion WHERE CQuestion.IDFrom = SBFROM.[SubQuestionId]) AS [SubQuestionId]
		,(SELECT TOP 1 CQuestion.IDTo FROM @CloneQuestionId CQuestion WHERE CQuestion.IDFrom = SBFROM.[RefSQId]) AS [RefSQId]
		,SBFROM.[Value],SBFROM.[Condition]
		,(SELECT TOP 1 CPage.IDTo FROM @ClonePageId CPage WHERE CPage.IDFrom = SBFROM.[JumpToSurveyPageId]) AS [JumpToSurveyPageId]
		,(SELECT TOP 1 CQuestion.IDTo FROM @CloneQuestionId CQuestion WHERE CQuestion.IDFrom = SBFROM.[JumpToSurveyQuestionId]) AS [JumpToSurveyQuestionId]
		,SBFROM.[Operator],SBFROM.[IsNext],SBFROM.[Index],SBFROM.[Type],SBFROM.[ModifiedBy],SBFROM.[CreatedBy]
		FROM [dbo].[SurveyBranching] SBFROM
		INNER JOIN [dbo].[SurveyQuestion] SQFROM ON SQFROM.[ID] = SBFROM.[SurveyQuestionId]
		WHERE SQFROM.[Status]<>-2 AND SQFROM.[SurveyTableId] = @SurveyTableFromId

		-- Copy Các Relation
		DECLARE @CloneRelation TABLE(
			IDFrom uniqueidentifier,
			IDTo uniqueidentifier
		);
		INSERT INTO @CloneRelation(IDFrom,IDTo)
		SELECT SRFROM.ID IDFrom,NEWID() AS IDTo
		FROM [dbo].[SurveyQuestionRelations] SRFROM
		INNER JOIN [dbo].[SurveyQuestion] SQFROM ON SQFROM.[ID] = SRFROM.[SurveyQuestionId]
		WHERE SQFROM.[Status]<>-2 AND SQFROM.[SurveyTableId] = @SurveyTableFromId 

		--SELECT * FROM @CloneRelation

		INSERT INTO [dbo].[SurveyQuestionRelations]([ID],SurveyBranchingId,SurveyQuestionId,ToSurveyQuestionId,[Type])
		SELECT (SELECT TOP 1 CRelation.IDTo FROM @CloneRelation CRelation WHERE CRelation.IDFrom = SRFrom.ID) as [ID]
		,(SELECT TOP 1 CBranching.IDTo FROM @CloneBranching CBranching WHERE CBranching.IDFrom = SRFrom.SurveyBranchingId) as [SurveyBranchingId]
		,(SELECT TOP 1 CQuestion.IDTo FROM @CloneQuestionId CQuestion WHERE CQuestion.IDFrom = SRFrom.SurveyQuestionId) as [SurveyQuestionId]
		,(SELECT TOP 1 CQuestion.IDTo FROM @CloneQuestionId CQuestion WHERE CQuestion.IDFrom = SRFrom.ToSurveyQuestionId) as [ToSurveyQuestionId]
		,SRFrom.[Type] as [Type]
		FROM [dbo].[SurveyQuestionRelations] SRFrom
		INNER JOIN [dbo].[SurveyQuestion] SQFROM ON SQFROM.[ID] = SRFROM.[SurveyQuestionId]
		WHERE SQFROM.[Status]<>-2 AND SQFROM.[SurveyTableId] = @SurveyTableFromId 
		
		COMMIT;
		RETURN 1;
	END TRY
	BEGIN CATCH
		--SELECT ERROR_MESSAGE() AS ErrorMessage;  
		ROLLBACK
		RETURN 0;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyTable_CopyPageQuestionBranching_BK]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyTable_CopyPageQuestionBranching_BK]
@SurveyTableFromId uniqueidentifier = null,
@SurveyTableToId uniqueidentifier = null
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		IF(@SurveyTableFromId IS NULL OR @SurveyTableToId IS NULL OR @SurveyTableFromId=@SurveyTableToId) RETURN 0;
		
		-- Copy các Page
		INSERT INTO [dbo].[SurveyPage] ([ID],[SurveyTableId],[Title],[Status],[Index],[ModifiedBy],[CreatedBy],[Options])
		SELECT NEWID() AS [ID],@SurveyTableToId AS [SurveyTableId],[Title],[Status],[Index],[ModifiedBy],[CreatedBy],[Options]
		FROM [dbo].[SurveyPage]
		WHERE [SurveyPage].[SurveyTableId] = @SurveyTableFromId AND [SurveyPage].[Status] <>-2

		-- Copy các Question
		INSERT INTO [dbo].[SurveyQuestion]([ID],[SQTId],[SurveyTableId],[SurveyPageId],[Title],[Description],[Value],[Status],[Required],[Formula],[FormulaMessage],[Index],[ModifiedBy],[CreatedBy],[Options])
		SELECT NEWID() AS [ID],SQFrom.SQTId,@SurveyTableToId as [SurveyTableId],
				(SELECT TOP 1 SPTO.ID FROM [dbo].[SurveyPage] SPTO 
				 WHERE SPTO.[SurveyTableId]=@SurveyTableToId AND SPTO.[Index]=SPFrom.[Index]) as [SurveyPageId],
				 SQFrom.[Title],SQFrom.[Description],SQFrom.[Value],SQFrom.[Status],SQFrom.[Required],SQFrom.[Formula],SQFrom.[FormulaMessage],SQFrom.[Index],SQFrom.[ModifiedBy],SQFrom.[CreatedBy],SQFrom.[Options]
		FROM [dbo].[SurveyQuestion] SQFrom
		INNER JOIN [dbo].[SurveyPage] SPFrom on SQFrom.[SurveyPageId] = SPFrom.[ID]
		WHERE SQFrom.[SurveyTableId] = @SurveyTableFromId AND SQFrom.[Status] <>-2

		-- Copy các Branching cha
		INSERT INTO [dbo].[SurveyBranching] ([ID],[ParentId],[SurveyQuestionId],[SubQuestionId],[Value],[Condition],[JumpToSurveyPageId],[JumpToSurveyQuestionId],[Operator],[IsNext],[Index],[ModifiedBy],[CreatedBy])
		SELECT NEWID() AS [ID],NULL AS [ParentId],
				(SELECT TOP 1 SQTO.[ID] FROM [dbo].[SurveyQuestion] SQTO WHERE SQTO.[SurveyTableId]=@SurveyTableToId AND SQTO.[Index]=SQFROM.[Index]) AS [SurveyQuestionId],
				SBFROM.[SubQuestionId],SBFROM.[Value],SBFROM.[Condition],
				(SELECT TOP 1 SP1.ID FROM [dbo].[SurveyPage] SP1 INNER JOIN SurveyPage SP2 ON SP1.[Index]=SP2.[Index] 
				WHERE SP1.[SurveyTableId] = @SurveyTableToId AND SP2.ID=SBFROM.[JumpToSurveyPageId]) AS [JumpToSurveyPageId],
				(SELECT TOP 1 SQ1.ID FROM [dbo].[SurveyQuestion] SQ1 INNER JOIN [SurveyQuestion] SQ2 ON SQ1.[Index] = SQ2.[Index]
				WHERE SQ1.[SurveyTableId]=@SurveyTableToId AND SQ2.[ID] = SBFROM.[JumpToSurveyQuestionId]) AS [JumpToSurveyQuestionId],
				SBFROM.[Operator],SBFROM.[IsNext],SBFROM.[Index],SBFROM.[ModifiedBy],SBFROM.[CreatedBy]
		FROM [dbo].[SurveyBranching] SBFROM
		INNER JOIN [dbo].[SurveyQuestion] SQFROM ON SQFROM.[ID] = SBFROM.[SurveyQuestionId]
		WHERE SQFROM.[Status]<>-2 AND SBFROM.[ParentId] IS NULL AND SQFROM.[SurveyTableId] = @SurveyTableFromId AND SBFROM.[Type] =1

		-- Copy các Branching con
		INSERT INTO [dbo].[SurveyBranching] ([ID],[ParentId],[SurveyQuestionId],[SubQuestionId],[Value],[Condition],[JumpToSurveyPageId],[JumpToSurveyQuestionId],[Operator],[IsNext],[Index],[ModifiedBy],[CreatedBy])
		SELECT NEWID() AS [ID],
				(SELECT TOP 1 SB1.ID FROM ([dbo].[SurveyBranching] SB1 INNER JOIN [dbo].[SurveyQuestion] SQ1 ON SB1.[SurveyQuestionId]=SQ1.[ID]) 
										INNER JOIN [dbo].[SurveyBranching] SB2 ON SB1.[Index] = SB2.[Index]
				WHERE SB2.[ID] = SBFROM.[ParentId] AND SQ1.[SurveyTableId] = @SurveyTableToId AND SB2.[SurveyQuestionId]=SBFROM.SurveyQuestionId) AS [ParentId],
				(SELECT TOP 1 SQTO.[ID] FROM [dbo].[SurveyQuestion] SQTO WHERE SQTO.[SurveyTableId]=@SurveyTableToId AND SQTO.[Index]=SQFROM.[Index]) AS [SurveyQuestionId],
				SBFROM.[SubQuestionId],SBFROM.[Value],SBFROM.[Condition],
				(SELECT TOP 1 SP1.ID FROM [dbo].[SurveyPage] SP1 INNER JOIN SurveyPage SP2 ON SP1.[Index]=SP2.[Index] 
				WHERE SP1.[SurveyTableId] = @SurveyTableToId AND SP2.ID=SBFROM.[JumpToSurveyPageId]) AS [JumpToSurveyPageId],
				(SELECT TOP 1 SQ1.ID FROM [dbo].[SurveyQuestion] SQ1 INNER JOIN [SurveyQuestion] SQ2 ON SQ1.[Index] = SQ2.[Index]
				WHERE SQ1.[SurveyTableId]=@SurveyTableToId AND SQ2.[ID] = SBFROM.[JumpToSurveyQuestionId]) AS [JumpToSurveyQuestionId],
				SBFROM.[Operator],SBFROM.[IsNext],SBFROM.[Index],SBFROM.[ModifiedBy],SBFROM.[CreatedBy]
		FROM [dbo].[SurveyBranching] SBFROM
		INNER JOIN [dbo].[SurveyQuestion] SQFROM ON SQFROM.[ID] = SBFROM.[SurveyQuestionId]
		WHERE SQFROM.[Status]<>-2 AND SBFROM.[ParentId] IS NOT NULL AND SQFROM.[SurveyTableId] = @SurveyTableFromId AND SBFROM.[Type] =1
		COMMIT;
		RETURN 1;
	END TRY
	BEGIN CATCH
		ROLLBACK
		RETURN 0;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyTable_Delete]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Delete from SurveyPermission

CREATE PROC [dbo].[vuthao_Survey_SurveyTable_Delete]
@SurveyTableId varchar(100)
AS
BEGIN
	Delete SurveyTable where ID = @SurveyTableId
	Delete SurveyPermission where SurveyTableId = @SurveyTableId
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyTable_EditTitle]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyTable_EditTitle]
	@ID uniqueidentifier,
	@Title nvarchar(255),
	@SurveyCategoryId int,
	@Options nvarchar(max)
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
	BEGIN TRY
		DECLARE @ErrorMessage VARCHAR(2000);

		UPDATE [dbo].[SurveyTable]
		SET [Title] = @Title,[Options] = @Options,[SurveyCategoryId] = @SurveyCategoryId
		WHERE [ID] = @ID

		COMMIT;
	END TRY
	BEGIN CATCH
	ROLLBACK;
	    SELECT @ErrorMessage = 'Error : ' + ERROR_MESSAGE()
	    RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyTable_GetByUserId]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[vuthao_Survey_SurveyTable_GetByUserId]
(
	@UserId varchar(100) = NULL,	-- Id user hiện hành
	@Status int = 2,				-- Deactive = -1, Draff = 0, Active = 1, All = 2, NotYetEvaluated = 3, Evaluated = 4
	@Limit int = 10,				-- Số lượng lấy tối đa mỗi lần truy xuất
	@Offset int = 0,					-- Vị trí bắt đầu lấy Data
	@Title nvarchar(255) = null,
	@SurveyCategoryId int = null,
	@FromDate datetime  =null,
	@ToDate datetime = null
)
AS
BEGIN
	IF(@UserId = '')	
		SET @UserId = NULL;

	IF(@Status = 3)
	BEGIN
		SELECT ST.*, SC.Title AS CategoryTitle, (SELECT COUNT(SR.ID) FROM SurveyResponses SR WHERE SR.SurveyTableId = ST.ID) AS Responses
		FROM SurveyTable ST 
		LEFT JOIN SurveyCategory SC ON ST.SurveyCategoryId = SC.ID
		WHERE ((ST.Permission IS NULL OR ST.Permission = '') OR @UserId IS NULL
		OR EXISTS(SELECT [ID] FROM SurveyPermission WHERE UserId = @UserId))
		AND (ST.[Status] <> -2 ) AND (NOT EXISTS(SELECT TOP 1 SR.[ID] FROM SurveyResponses SR WHERE SR.SurveyTableId = ST.ID))
		AND (@Title IS NULL OR ST.[Title] LIKE ('%'+@Title + '%'))
		AND (@SurveyCategoryId IS NULL OR ST.SurveyCategoryId = @SurveyCategoryId)
		AND ((@FromDate IS NULL OR (ST.[StartDate] >= @FromDate AND (@ToDate IS NULL OR ST.[StartDate] <= @ToDate))) AND
			(@ToDate IS NULL OR (ST.[DueDate] <= @ToDate AND (@FromDate IS NULL OR ST.[DueDate] >= @FromDate))))

		--AND ((@FromDate IS NULL AND (@ToDate IS NULL OR ST.[StartDate] IS NULL OR ST.[StartDate]<= @ToDate)) OR
		--		(@ToDate IS NULL AND (ST.[DueDate] IS NULL OR  ST.[DueDate] >= @FromDate)) OR
		--		(ST.[DueDate] IS NULL AND ST.[StartDate] IS NULL) OR
		--		(NOT (ST.[StartDate] >@ToDate  OR ST.[DueDate] < @FromDate)))	
		ORDER BY Created DESC
		OFFSET @Offset ROWS
		FETCH NEXT @Limit ROWS ONLY
	END
	ELSE IF(@Status = 4)
	BEGIN
		SELECT ST.*, SC.Title AS CategoryTitle, (SELECT COUNT(SR.ID) FROM SurveyResponses SR WHERE SR.SurveyTableId = ST.ID) AS Responses
		FROM SurveyTable ST 
		LEFT JOIN SurveyCategory SC on ST.SurveyCategoryId = SC.ID
		WHERE ((ST.Permission IS NULL OR ST.Permission = '') OR @UserId IS NULL
		OR EXISTS(SELECT [ID] FROM SurveyPermission WHERE UserId = @UserId))
		AND (ST.[Status] <> -2) AND (EXISTS(SELECT top 1 SR.[ID] FROM SurveyResponses SR WHERE SR.SurveyTableId = ST.ID ))
		AND (@Title IS NULL OR ST.[Title] LIKE ('%'+@Title + '%'))
		AND (@SurveyCategoryId IS NULL OR ST.SurveyCategoryId = @SurveyCategoryId)
		AND ((@FromDate IS NULL OR (ST.[StartDate] >= @FromDate AND (@ToDate IS NULL OR ST.[StartDate] <= @ToDate))) AND
			(@ToDate IS NULL OR (ST.[DueDate] <= @ToDate AND (@FromDate IS NULL OR ST.[DueDate] >= @FromDate))))
		--AND ((@FromDate IS NULL AND (@ToDate IS NULL OR ST.[StartDate] IS NULL OR ST.[StartDate]<= @ToDate)) OR
		--		(@ToDate IS NULL AND (ST.[DueDate] IS NULL OR  ST.[DueDate] >= @FromDate)) OR
		--		(ST.[DueDate] IS NULL AND ST.[StartDate] IS NULL) OR
		--		(NOT (ST.[StartDate] >@ToDate  OR ST.[DueDate] < @FromDate)))	
		ORDER BY Created DESC
		OFFSET @Offset ROWS
		FETCH NEXT @Limit ROWS ONLY
	END
	ELSE
	BEGIN
		SELECT ST.*, SC.Title AS CategoryTitle, (SELECT COUNT(SR.ID) FROM SurveyResponses SR WHERE SR.SurveyTableId = ST.ID) AS Responses
		FROM SurveyTable ST 
		LEFT JOIN SurveyCategory SC on ST.SurveyCategoryId = SC.ID
		WHERE ((ST.Permission IS NULL OR ST.Permission = '') OR @UserId IS NULL	OR EXISTS(SELECT SP.[ID] FROM SurveyPermission SP WHERE SP.UserId = @UserId))
		AND (ST.[Status] <> -2 AND (@Status = 2 OR ST.[Status] = @Status))
		AND (@Title IS NULL OR ST.[Title] LIKE ('%'+@Title + '%'))
		AND (@SurveyCategoryId IS NULL OR ST.SurveyCategoryId = @SurveyCategoryId)
		AND ((@FromDate IS NULL OR (ST.[StartDate] >= @FromDate AND (@ToDate IS NULL OR ST.[StartDate] <= @ToDate))) AND
			(@ToDate IS NULL OR (ST.[DueDate] <= @ToDate AND (@FromDate IS NULL OR ST.[DueDate] >= @FromDate))))
		--AND ((@FromDate IS NULL AND (@ToDate IS NULL OR ST.[StartDate] IS NULL OR ST.[StartDate]<= @ToDate)) OR
		--		(@ToDate IS NULL AND (ST.[DueDate] IS NULL OR  ST.[DueDate] >= @FromDate)) OR
		--		(ST.[DueDate] IS NULL AND ST.[StartDate] IS NULL) OR
		--		(NOT (ST.[StartDate] >@ToDate  OR ST.[DueDate] < @FromDate)))	
		ORDER BY Created DESC
		OFFSET @Offset ROWS
		FETCH NEXT @Limit ROWS ONLY
	END
END

GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyTable_GetCountDashboard]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[vuthao_Survey_SurveyTable_GetCountDashboard]
@UserId varchar(100) = NULL		-- Id user hiện hành
AS
BEGIN
	DECLARE @dt date = Convert(varchar(10), GETDATE(), 21);
	Declare @iN_OverDue int =0, @iN_Today int, @iN_NextTo int, @iN_NotYetEval int, @iN_Evaluating int, @iN_Completed int;

	----------- Qúa hạn -----------
	SET @iN_OverDue = (SELECT Count(ST.[ID])
	FROM SurveyTable ST 
	where 
	((ST.Permission IS NULL OR ST.Permission = '') OR (@UserId IS NULL) OR Exists(select *from SurveyPermission where UserId = @UserId))
	AND (ST.[Status] = 1 )
	AND (ST.DueDate < @dt)
	AND (NOT EXISTS (SELECT SR.ID FROM [dbo].[SurveyResponses] SR
							WHERE SR.[SurveyTableId] = ST.[ID] AND [Status]=1)))

	------------ Hoàn tất hôm nay ----------
	SET @iN_Today = (SELECT Count(ST.ID)
	FROM SurveyTable ST 
	where 
	((ST.Permission IS NULL OR ST.Permission = '') OR (@UserId IS NULL) OR Exists(select *from SurveyPermission where UserId = @UserId))
	AND (ST.[Status] = 1 )
	AND (ST.DueDate = @dt)
	AND (ST.[AllowMultipleResponses] = 1 OR 
			NOT EXISTS (SELECT SR.ID FROM [dbo].[SurveyResponses] SR
							WHERE SR.[SurveyTableId] = ST.[ID] AND [Status]=1)))

	------------ Sắp tới ----------
	SET @iN_NextTo = (SELECT Count(ST.ID)
	FROM SurveyTable ST 
	where 
	((ST.Permission IS NULL OR ST.Permission = '') OR (@UserId IS NULL) OR Exists(select *from SurveyPermission where UserId = @UserId))
	AND (ST.[Status] = 1 )
	AND (ST.DueDate > @dt)
	AND (ST.[AllowMultipleResponses] = 1 OR 
			NOT EXISTS (SELECT SR.ID FROM [dbo].[SurveyResponses] SR
							WHERE SR.[SurveyTableId] = ST.[ID] AND [Status]=1)))
	------------ Chưa đánh giá ----------
	SET @iN_NotYetEval = (SELECT COUNT(ST.ID)
	FROM SurveyTable ST
	WHERE  ST.[Status] = 1 
	AND ((ST.DueDate is null or (ST.DueDate >= @dt)) AND
				(ST.[StartDate] <= @dt))
	AND ((ST.Permission IS NULL OR ST.Permission = '') OR 
		EXISTS (SELECT SP.[ID] FROM SurveyPermission SP WHERE SP.UserId = @UserId AND SP.[SurveyTableId] = ST.ID))
	AND	NOT EXISTS(SELECT [SurveyResponses].[ID] FROM [dbo].[SurveyResponses] WHERE [SurveyResponses].SurveyTableId = ST.ID
							AND [SurveyResponses].[Status] IN (0,1)
							AND [SurveyResponses].[UserId] = @UserID)
	)

	------------ Đang đánh giá ----------
	SET @iN_Evaluating = (SELECT COUNT(ST.ID)
	FROM SurveyTable ST
	WHERE  ST.[Status] = 1 
	AND ((ST.DueDate is null or (ST.DueDate >= @dt)) AND
				(ST.[StartDate] <= @dt))
	AND ((ST.Permission IS NULL OR ST.Permission = '') OR 
		EXISTS (SELECT SP.[ID] FROM SurveyPermission SP WHERE SP.UserId = @UserId AND SP.[SurveyTableId] = ST.ID))
	AND	EXISTS (SELECT TOP 1 SR.[ID] FROM [dbo].[SurveyResponses] SR WHERE SR.SurveyTableId = ST.ID
								AND SR.[Status] = 0
								AND (@UserId IS NULL OR SR.[UserId] = @UserID))
	)

	------------ Đã hoàn tất ----------
	SET @iN_Completed = (	SELECT COUNT(SR.[ID])
	FROM [SurveyResponses] SR
	INNER JOIN (SELECT ST.* FROM [SurveyTable] ST
				WHERE ST.[Status] = 1
				AND ((ST.Permission IS NULL OR ST.Permission = '') OR
					 (EXISTS (SELECT TOP 1 SP.[ID] FROM SurveyPermission SP 
							WHERE SP.UserId = @UserId
							AND SP.[SurveyTableId] = ST.ID)))) STFixed 
	ON STFixed.ID = SR.[SurveyTableId]
	WHERE SR.UserId = @UserId
	AND SR.[Status] = 1
	)

	select @iN_OverDue as Num_OverDue, @iN_Today as Num_Today, @iN_NextTo as Num_NextTo, @iN_NotYetEval as Num_NotYetEval, @iN_Evaluating as Num_Evaluating, @iN_Completed as Num_Completed
END

GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyTable_GetEvaluated]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[vuthao_Survey_SurveyTable_GetEvaluated]
@UserId varchar(100) = NULL		-- Id user hiện hành
AS
BEGIN
	SELECT A.*, B.Title as CategoryTitle
	FROM SurveyTable A 
	left join SurveyCategory B on A.SurveyCategoryId = B.ID
	where ((A.Permission IS NULL OR A.Permission = '') OR (@UserId IS NULL OR @UserId = '')
	OR Exists(select *from SurveyPermission where UserId = @UserId))
	AND (A.[Status] <> -2 ) AND (Exists(select top 1 *from SurveyResponses SR where SR.SurveyTableId = A.ID))
	Order by Created desc
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyTable_GetNotYetEvaluated]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[vuthao_Survey_SurveyTable_GetNotYetEvaluated]
@UserId varchar(100) = NULL		-- Id user hiện hành
AS
BEGIN
	SELECT A.*, B.Title as CategoryTitle
	FROM SurveyTable A 
	left join SurveyCategory B on A.SurveyCategoryId = B.ID
	where ((A.Permission IS NULL OR A.Permission = '') OR (@UserId IS NULL OR @UserId = '')
	OR Exists(select *from SurveyPermission where UserId = @UserId))
	AND (A.[Status] <> -2 ) AND (Not Exists(select top 1 *from SurveyResponses SR where SR.SurveyTableId = A.ID))
	Order by Created desc
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyTable_GetSurveyDashBoardData]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyTable_GetSurveyDashBoardData]
	@UserID uniqueidentifier = null,
	@Type varchar(10) = 'All',		-- All | Pending | InProgress | Completed
	@Limit int = 5,
	@Offset int = 0

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @dtNow date =Convert(varchar(10), GETDATE(), 21);
	if(@Limit < 1)
	BEGIN
		SELECT ST.*, SC.Title AS CategoryTitle
			,(CASE WHEN @Type != 'Completed' AND @Type!='All' THEN NULL
				ELSE (SELECT TOP 1 SR.[ID] FROM [dbo].[SurveyResponses] SR
						WHERE SR.SurveyTableId = ST.ID
						AND SR.[Status] = 1
						AND (@UserId IS NULL OR SR.[UserId] = @UserID)
						ORDER BY SR.[CompletedDate] DESC) END) AS ReviewID
		FROM SurveyTable ST
			LEFT JOIN SurveyCategory SC ON ST.SurveyCategoryId = SC.ID
		WHERE  ST.[Status] = 1 
		AND ((ST.Permission IS NULL OR ST.Permission = '') OR 
		(EXISTS (SELECT TOP 1 SP.[ID] FROM SurveyPermission SP 
					WHERE SP.UserId = @UserId 
					AND SP.[SurveyTableId] = ST.ID)))
		AND (@Type = 'All' OR
			(@Type = 'Pending' AND ((ST.DueDate is null or (ST.DueDate >= @dtNow)) AND (ST.[StartDate] <= @dtNow)) AND
			NOT EXISTS(SELECT [SurveyResponses].[ID] FROM [dbo].[SurveyResponses] WHERE [SurveyResponses].SurveyTableId = ST.ID
										AND [SurveyResponses].[Status] IN (0,1)
										AND (@UserId IS NULL OR [SurveyResponses].[UserId] = @UserID))) OR
			(@Type = 'InProgress' AND ((ST.DueDate is null or (ST.DueDate >= @dtNow)) AND (ST.[StartDate] <= @dtNow)) AND
			EXISTS (SELECT TOP 1 SR.[ID] FROM [dbo].[SurveyResponses] SR WHERE SR.SurveyTableId = ST.ID
									AND SR.[Status] = 0
									AND (@UserId IS NULL OR SR.[UserId] = @UserID))) OR
			(@Type = 'Completed'	AND 
			(EXISTS (SELECT TOP 1 SR.[ID] FROM [dbo].[SurveyResponses] SR
								WHERE SR.SurveyTableId = ST.ID
								AND SR.[Status] = 1
								AND (@UserId IS NULL OR [UserId] = @UserID)))		AND
			(NOT EXISTS (SELECT TOP 1 SR.[ID] FROM [dbo].[SurveyResponses] SR
								WHERE SR.SurveyTableId = ST.ID
								AND SR.[Status] = 0
								AND (@UserId IS NULL OR [UserId] = @UserID)))))
		ORDER BY Created DESC
	END
	ELSE
	BEGIN
		SELECT ST.*, SC.Title AS CategoryTitle
			,(CASE WHEN @Type != 'Completed' AND @Type!='All' THEN NULL
				ELSE (SELECT TOP 1 SR.[ID] FROM [dbo].[SurveyResponses] SR
						WHERE SR.SurveyTableId = ST.ID
						AND SR.[Status] = 1
						AND (@UserId IS NULL OR SR.[UserId] = @UserID)
						ORDER BY SR.[CompletedDate] DESC) END) AS ReviewID
		FROM SurveyTable ST
			LEFT JOIN SurveyCategory SC ON ST.SurveyCategoryId = SC.ID
		WHERE  ST.[Status] = 1 
		AND ((ST.Permission IS NULL OR ST.Permission = '') OR 
		(EXISTS (SELECT TOP 1 SP.[ID] FROM SurveyPermission SP 
					WHERE SP.UserId = @UserId 
					AND SP.[SurveyTableId] = ST.ID)))
		AND (@Type = 'All' OR
			(@Type = 'Pending' AND ((ST.DueDate is null or (ST.DueDate >= @dtNow)) AND (ST.[StartDate] <= @dtNow)) AND
			NOT EXISTS(SELECT [SurveyResponses].[ID] FROM [dbo].[SurveyResponses] WHERE [SurveyResponses].SurveyTableId = ST.ID
										AND [SurveyResponses].[Status] IN (0,1)
										AND (@UserId IS NULL OR [SurveyResponses].[UserId] = @UserID))) OR
			(@Type = 'InProgress' AND ((ST.DueDate is null or (ST.DueDate >= @dtNow)) AND (ST.[StartDate] <= @dtNow)) AND
			EXISTS (SELECT TOP 1 SR.[ID] FROM [dbo].[SurveyResponses] SR WHERE SR.SurveyTableId = ST.ID
									AND SR.[Status] = 0
									AND (@UserId IS NULL OR SR.[UserId] = @UserID))) OR
			(@Type = 'Completed'	AND 
			(EXISTS (SELECT TOP 1 SR.[ID] FROM [dbo].[SurveyResponses] SR
								WHERE SR.SurveyTableId = ST.ID
								AND SR.[Status] = 1
								AND (@UserId IS NULL OR [UserId] = @UserID)))		AND
			(NOT EXISTS (SELECT TOP 1 SR.[ID] FROM [dbo].[SurveyResponses] SR
								WHERE SR.SurveyTableId = ST.ID
								AND SR.[Status] = 0
								AND (@UserId IS NULL OR [UserId] = @UserID)))))
		ORDER BY Created DESC
		OFFSET @Offset ROWS
		FETCH NEXT @Limit ROWS ONLY
	END

END

GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyTable_Reset]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		nguyenhn
-- Create date: 22.11.2017
-- Description:	
-- =============================================

CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyTable_Reset] 
	-- Add the parameters for the stored procedure here
	@ID uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRAN
	BEGIN TRY
		DECLARE @Status smallint = NULL;
		DECLARE @ExistsId uniqueidentifier = NULL;
		IF(@ID IS NULL)
		BEGIN
			COMMIT;
			RETURN 0;
		END
		SELECT TOP 1 @ExistsId = [ID] ,@Status = [SurveyTable].[Status]
		FROM SurveyTable WHERE SurveyTable.ID = @ID

		IF(@ExistsId IS NULL OR @Status IS NULL OR @Status <> -1)
		BEGIN
			COMMIT;
			RETURN 0;
		END

		DELETE FROM [dbo].[SurveyResponsesValue]
		WHERE [SurveyQuestionId] in (SELECT [SurveyQuestion].[ID]
									FROM [dbo].[SurveyQuestion]
									WHERE [SurveyQuestion].[SurveyTableId] = @ID)
		
		DELETE FROM [dbo].[SurveyResponses]
		WHERE [SurveyResponses].[SurveyTableId] = @ID;
		
		UPDATE [dbo].[SurveyQuestion]
		SET [ValueCount] = NULL,[AnsweredCount]=0,[SkippedCount]=0,OtherValueCount=null
		WHERE [SurveyTableId] = @ID

		COMMIT;
		RETURN 1;
	END TRY
	BEGIN CATCH
		ROLLBACK
		RETURN 0;
	END CATCH
END
/*
DECLARE @Result int;
exec @Result = vuthao_Survey_SurveyTable_Reset @ID=N'0ed8e69b-ab20-4ad1-9869-d5178638e2ee';
select @Result

*/
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyTable_Select]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyTable_Select]
	@ID uniqueidentifier,
	@Title nvarchar(255),
	@Status tinyint,
	@fDate datetime,
	@tDate datetime,
	@SurveyCategoryId int,
	@Description nvarchar(max)
AS
BEGIN
	SELECT * 
	FROM SurveyTable
	WHERE (@ID is null or [ID] = @ID)
	AND (@Title is null or [Title] LIKE '%'+@Title+'%')
	AND (@Status is null or [Status] = @Status)
	AND (@fDate is null or [StartDate] >=@fDate)
	AND (@tDate is null or [StartDate] < @tDate)
	AND (@SurveyCategoryId is null or [SurveyCategoryId] = @SurveyCategoryId)
	AND (@Description is null or [Description] like '%'+@Description+'%')
END 
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyTable_UserChuaDanhGia]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyTable_UserChuaDanhGia]
	@UserId nvarchar(100) = NULL,
	@Title nvarchar(255) = null,
	@SurveyCategoryId int = null,
	@FromDate datetime  =null,
	@ToDate datetime = null,
	@Type smallint= 2,	-- 0 : Chưa đánh giá, 1 : Đang đánh giá, 2 : Đang hoặc chưa đánh giá
	@IsQuiz smallint=2,	-- 0 : <> Quiz, 1 : Quiz, 2 : Tất cả
	@Limit int = 100,	-- Số lượng lấy tối đa mỗi lần truy xuất
	@Offset int = 0		-- Vị trí bắt đầu lấy Data
AS
BEGIN
	IF (@UserId = '')
	BEGIN
		SET @UserId = NULL
	END

	DECLARE @dtNow date =Convert(varchar(10), GETDATE(), 21);
	IF(@Limit < 1)
	BEGIN
		SELECT ST.*, SC.Title AS CategoryTitle
		FROM SurveyTable ST
			LEFT JOIN SurveyCategory SC ON ST.SurveyCategoryId = SC.ID
		WHERE  ST.[Status] = 1 
		AND ((ST.DueDate is null or (ST.DueDate >= @dtNow)) AND
				(ST.[StartDate] <= @dtNow))
		AND (@Title IS NULL OR ST.[Title] LIKE ('%'+@Title + '%'))
		AND (@SurveyCategoryId IS NULL OR ST.SurveyCategoryId = @SurveyCategoryId)
		AND ((@FromDate IS NULL OR (ST.[StartDate] >= @FromDate AND (@ToDate IS NULL OR ST.[StartDate] <= @ToDate))) AND
			(@ToDate IS NULL OR (ST.[DueDate] <= @ToDate AND (@FromDate IS NULL OR ST.[DueDate] >= @FromDate))))
	
		AND ((ST.Permission IS NULL OR ST.Permission = '') OR 
			(EXISTS (SELECT TOP 1 SP.[ID] FROM SurveyPermission SP 
						WHERE SP.UserId = @UserId 
						AND SP.[SurveyTableId] = ST.ID)))
		AND (((@Type IS NULL OR @Type = 2)	AND
		-- Có 1 responses đang đánh giá hoặc không có bất cứ đánh giá nào hoàn tất
			 ((EXISTS (SELECT TOP 1 SR.[ID] FROM [dbo].[SurveyResponses] SR WHERE SR.SurveyTableId = ST.ID
										AND SR.[Status] = 0
										AND (@UserId IS NULL OR SR.[UserId] = @UserID))) OR
				(NOT EXISTS(SELECT [SurveyResponses].[ID] FROM [dbo].[SurveyResponses] WHERE [SurveyResponses].SurveyTableId = ST.ID
									AND [SurveyResponses].[Status] = 1
									AND (@UserId IS NULL OR [SurveyResponses].[UserId] = @UserID))))) OR
			(@Type = 0 AND NOT EXISTS(SELECT [SurveyResponses].[ID] FROM [dbo].[SurveyResponses] WHERE [SurveyResponses].SurveyTableId = ST.ID
										AND [SurveyResponses].[Status] IN (0,1)
										AND (@UserId IS NULL OR [SurveyResponses].[UserId] = @UserID))) OR
			(@Type = 1 AND  EXISTS (SELECT TOP 1 SR.[ID] FROM [dbo].[SurveyResponses] SR WHERE SR.SurveyTableId = ST.ID
									AND SR.[Status] = 0
									AND (@UserId IS NULL OR SR.[UserId] = @UserID))))
		AND (@IsQuiz =2 OR (@IsQuiz=0 and ST.IsScoring=0) OR (@IsQuiz=1 and ST.IsScoring=1))

		ORDER BY Created DESC
	END
	ELSE
	BEGIN
		SELECT ST.*, SC.Title as CategoryTitle
		FROM SurveyTable ST
			LEFT JOIN SurveyCategory SC on ST.SurveyCategoryId = SC.ID
		WHERE  ST.[Status] = 1 
		AND ((ST.DueDate is null or (ST.DueDate >= @dtNow)) AND
				(ST.[StartDate] <= @dtNow))
		AND (@Title IS NULL OR ST.[Title] LIKE ('%'+@Title + '%'))
		AND (@SurveyCategoryId IS NULL OR ST.SurveyCategoryId = @SurveyCategoryId)
		AND ((@FromDate IS NULL OR (ST.[StartDate] >= @FromDate AND (@ToDate IS NULL OR ST.[StartDate] <= @ToDate))) AND
			(@ToDate IS NULL OR (ST.[DueDate] <= @ToDate AND (@FromDate IS NULL OR ST.[DueDate] >= @FromDate))))

		AND ((ST.Permission IS NULL OR ST.Permission = '') OR 
			(EXISTS (SELECT TOP 1 SP.[ID] FROM SurveyPermission SP 
							WHERE SP.UserId = @UserId 
							AND SP.[SurveyTableId] = ST.ID)))

		-- Có 1 responses đang đánh giá hoặc không có bất cứ đánh giá nào hoàn tất
		AND (((@Type IS NULL OR @Type = 2)	AND
		-- Có 1 responses đang đánh giá hoặc không có bất cứ đánh giá nào hoàn tất
			 ((EXISTS (SELECT TOP 1 SR.[ID] FROM [dbo].[SurveyResponses] SR WHERE SR.SurveyTableId = ST.ID
										AND SR.[Status] = 0
										AND (@UserId IS NULL OR SR.[UserId] = @UserID))) OR
				(NOT EXISTS(SELECT [SurveyResponses].[ID] FROM [dbo].[SurveyResponses] WHERE [SurveyResponses].SurveyTableId = ST.ID
									AND [SurveyResponses].[Status] = 1
									AND (@UserId IS NULL OR [SurveyResponses].[UserId] = @UserID))))) OR
			(@Type = 0 AND NOT EXISTS(SELECT [SurveyResponses].[ID] FROM [dbo].[SurveyResponses] WHERE [SurveyResponses].SurveyTableId = ST.ID
										AND [SurveyResponses].[Status] IN (0,1)
										AND (@UserId IS NULL OR [SurveyResponses].[UserId] = @UserID))) OR
			(@Type = 1 AND  EXISTS (SELECT TOP 1 SR.[ID] FROM [dbo].[SurveyResponses] SR WHERE SR.SurveyTableId = ST.ID
									AND SR.[Status] = 0
									AND (@UserId IS NULL OR SR.[UserId] = @UserID))))
		AND (@IsQuiz =2 OR (@IsQuiz=0 and ST.IsScoring=0) OR (@IsQuiz=1 and ST.IsScoring=1))
		ORDER BY Created DESC
		OFFSET @Offset ROWS
		FETCH NEXT @Limit ROWS ONLY
	END
END

GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyTable_UserChuaDanhGia_Count]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyTable_UserChuaDanhGia_Count]
	@UserId nvarchar(100)
	,@IsQuiz smallint=2	-- 0 : <> Quiz, 1 : Quiz, 2 : Tất cả
AS
BEGIN
	SELECT COUNT(ST.ID)
	FROM SurveyTable ST
	WHERE  ST.[Status] = 1 
	AND ((ST.Permission IS NULL OR ST.Permission = '') OR 
		(@UserId IS NULL OR
			EXISTS (SELECT SP.[ID] FROM SurveyPermission SP 
						WHERE SP.UserId = @UserId 
						AND SP.[SurveyTableId] = ST.ID)))

	-- Có 1 responses đang đánh giá hoặc không có bất cứ đánh giá nào hoàn tất
	AND ((EXISTS (SELECT TOP 1 SR.[ID] FROM [dbo].[SurveyResponses] SR WHERE SR.SurveyTableId = ST.ID
								AND SR.[Status] = 0
								AND (@UserId IS NULL OR SR.[UserId] = @UserID))) OR
		(NOT EXISTS(SELECT [SurveyResponses].[ID] FROM [dbo].[SurveyResponses] WHERE [SurveyResponses].SurveyTableId = ST.ID
							AND [SurveyResponses].[Status] = 1
							AND (@UserId IS NULL OR [SurveyResponses].[UserId] = @UserID))))
	AND (@IsQuiz =2 OR (@IsQuiz=0 and ST.IsScoring=0) OR (@IsQuiz=1 and ST.IsScoring=1))
END
GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyTable_UserDaDanhGia]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyTable_UserDaDanhGia]
	@UserId nvarchar(100),
	@Title nvarchar(255) = null,
	@SurveyCategoryId int = null,
	@FromDate datetime  =null,
	@ToDate datetime = null,
	@Limit int = 10,	-- Số lượng lấy tối đa mỗi lần truy xuất
	@Offset int = 0		-- Vị trí bắt đầu lấy Data
AS
BEGIN
	IF (@UserId = '')
	BEGIN
		SET @UserId = null
	END

	IF(@Limit < 1)
	BEGIN
		SELECT ST.*, SC.Title AS CategoryTitle
		FROM SurveyTable ST
		LEFT JOIN SurveyCategory SC ON ST.SurveyCategoryId = SC.ID
		WHERE  ST.[Status] = 1
		AND (@Title IS NULL OR ST.[Title] LIKE ('%'+@Title + '%'))
		AND (@SurveyCategoryId IS NULL OR ST.SurveyCategoryId = @SurveyCategoryId)
		AND ((@FromDate IS NULL OR (ST.[StartDate] >= @FromDate AND (@ToDate IS NULL OR ST.[StartDate] <= @ToDate))) AND
			(@ToDate IS NULL OR (ST.[DueDate] <= @ToDate AND (@FromDate IS NULL OR ST.[DueDate] >= @FromDate))))
		--AND ((@FromDate IS NULL AND (@ToDate IS NULL OR ST.[StartDate] IS NULL OR ST.[StartDate]<= @ToDate)) OR
		--		(@ToDate IS NULL AND (ST.[DueDate] IS NULL OR  ST.[DueDate] >= @FromDate)) OR
		--		(ST.[DueDate] IS NULL AND ST.[StartDate] IS NULL) OR
		--		(NOT (ST.[StartDate] >@ToDate  OR ST.[DueDate] < @FromDate)))
		AND ((ST.Permission IS NULL OR ST.Permission = '') 
		OR (Exists (SELECT TOP 1 SP.[ID] FROM SurveyPermission SP 
							WHERE @UserId IS NULL OR SP.UserId = @UserId
							AND SP.[SurveyTableId] = ST.ID)))
		AND (EXISTS (SELECT TOP 1 SR.[ID] FROM [dbo].[SurveyResponses] SR
								WHERE SR.SurveyTableId = ST.ID
								AND SR.[Status] = 1
								AND (@UserId IS NULL OR [UserId] = @UserID)))
		ORDER BY Created DESC
	END
	ELSE
	BEGIN
		SELECT ST.*, SC.Title AS CategoryTitle
		FROM SurveyTable ST
		LEFT JOIN SurveyCategory SC ON ST.SurveyCategoryId = SC.ID
		WHERE  ST.[Status] = 1
		AND (@Title IS NULL OR ST.[Title] LIKE ('%'+@Title + '%'))
		AND (@SurveyCategoryId IS NULL OR ST.SurveyCategoryId = @SurveyCategoryId)
		AND ((@FromDate IS NULL OR (ST.[StartDate] >= @FromDate AND (@ToDate IS NULL OR ST.[StartDate] <= @ToDate))) AND
			(@ToDate IS NULL OR (ST.[DueDate] <= @ToDate AND (@FromDate IS NULL OR ST.[DueDate] >= @FromDate))))
		--AND ((@FromDate IS NULL AND (@ToDate IS NULL OR ST.[StartDate] IS NULL OR ST.[StartDate]<= @ToDate)) OR
		--		(@ToDate IS NULL AND (ST.[DueDate] IS NULL OR  ST.[DueDate] >= @FromDate)) OR
		--		(ST.[DueDate] IS NULL AND ST.[StartDate] IS NULL) OR
		--		(NOT (ST.[StartDate] >@ToDate  OR ST.[DueDate] < @FromDate)))
		AND ((ST.Permission IS NULL OR ST.Permission = '') 
		OR (Exists (SELECT TOP 1 SP.[ID] FROM SurveyPermission SP 
							WHERE @UserId IS NULL OR SP.UserId = @UserId
							AND SP.[SurveyTableId] = ST.ID)))
		AND (EXISTS (SELECT TOP 1 SR.[ID] FROM [dbo].[SurveyResponses] SR
								WHERE SR.SurveyTableId = ST.ID
								AND SR.[Status] = 1
								AND (@UserId IS NULL OR [UserId] = @UserID)))
		ORDER BY Created DESC
		OFFSET @Offset ROWS
		FETCH NEXT @Limit ROWS ONLY
	END
END

GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyTable_UserDaDanhGia_Count]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyTable_UserDaDanhGia_Count]
	@UserId nvarchar(250)
AS
BEGIN
	SELECT COUNT(SR.[ID])
	FROM [SurveyResponses] SR
	INNER JOIN (SELECT ST.* FROM [SurveyTable] ST
				WHERE ST.[Status] = 1
				AND ((ST.Permission IS NULL OR ST.Permission = '') OR
					 (EXISTS (SELECT TOP 1 SP.[ID] FROM SurveyPermission SP 
							WHERE SP.UserId = @UserId
							AND SP.[SurveyTableId] = ST.ID)))) STFixed 
	ON STFixed.ID = SR.[SurveyTableId]
	WHERE SR.UserId = @UserId
	AND SR.[Status] = 1
END

GO
/****** Object:  StoredProcedure [dbo].[vuthao_Survey_SurveyTable_UserListByDate]    Script Date: 5/4/2023 5:47:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[vuthao_Survey_SurveyTable_UserListByDate] 
	-- Add the parameters for the stored procedure here
	@UserId varchar(100) = NULL	,-- Id user hiện hành
	@Title nvarchar(255) = null,
	@SurveyCategoryId int = null,
	@Type smallint = -1,	-- Loại lọc:: -1:Trễ hạn, 0: Hôm nay, 1: Sắp tới
	@Limit int = 10,	-- Số lượng lấy tối đa mỗi lần truy xuất
	@Offset int = 0		-- Vị trí bắt đầu lấy Data
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(@Limit < 1)
	BEGIN
		IF(@Type = -1)
			BEGIN
			SELECT ST.*, SC.Title AS CategoryTitle
			FROM SurveyTable ST 
			LEFT JOIN SurveyCategory SC ON ST.SurveyCategoryId = SC.ID
			where 
			((ST.Permission IS NULL OR ST.Permission = '') OR (@UserId IS NULL) OR Exists(select *from SurveyPermission where UserId = @UserId))
			AND (ST.[Status] = 1 )
			AND (ST.DueDate < Convert(varchar(10), GETDATE(), 21))
			AND (NOT EXISTS (SELECT SR.ID FROM [dbo].[SurveyResponses] SR
									WHERE SR.[SurveyTableId] = ST.[ID] AND [Status]=1))
			AND (@Title IS NULL OR ST.[Title] LIKE ('%'+@Title + '%'))
			AND (@SurveyCategoryId IS NULL OR ST.SurveyCategoryId = @SurveyCategoryId)
			ORDER BY Created DESC
			END
		ELSE
			BEGIN
				IF(@Type = 0)
				BEGIN
					SELECT ST.*, SC.Title AS CategoryTitle
					FROM SurveyTable ST 
					LEFT JOIN SurveyCategory SC ON ST.SurveyCategoryId = SC.ID
					where 
					((ST.Permission IS NULL OR ST.Permission = '') OR (@UserId IS NULL) OR Exists(select *from SurveyPermission where UserId = @UserId))
					AND (ST.[Status] = 1 )
					AND (ST.DueDate = Convert(varchar(10), GETDATE(), 21))
					AND (ST.[AllowMultipleResponses] = 1 OR 
							NOT EXISTS (SELECT SR.ID FROM [dbo].[SurveyResponses] SR
											WHERE SR.[SurveyTableId] = ST.[ID] AND [Status]=1))
					AND (@Title IS NULL OR ST.[Title] LIKE ('%'+@Title + '%'))
					AND (@SurveyCategoryId IS NULL OR ST.SurveyCategoryId = @SurveyCategoryId)
					ORDER BY Created DESC
				END
				ELSE
				BEGIN
					SELECT ST.*, SC.Title AS CategoryTitle
					FROM SurveyTable ST 
					LEFT JOIN SurveyCategory SC ON ST.SurveyCategoryId = SC.ID
					where 
					((ST.Permission IS NULL OR ST.Permission = '') OR (@UserId IS NULL) OR Exists(select *from SurveyPermission where UserId = @UserId))
					AND (ST.[Status] = 1 )
					AND (ST.DueDate > Convert(varchar(10), GETDATE(), 21))
					AND (ST.[AllowMultipleResponses] = 1 OR 
							NOT EXISTS (SELECT SR.ID FROM [dbo].[SurveyResponses] SR
											WHERE SR.[SurveyTableId] = ST.[ID] AND [Status]=1))
					AND (@Title IS NULL OR ST.[Title] LIKE ('%'+@Title + '%'))
					AND (@SurveyCategoryId IS NULL OR ST.SurveyCategoryId = @SurveyCategoryId)
					ORDER BY Created DESC
				END
			END
	END
	ELSE
	BEGIN
		IF (@Type = -1)
			BEGIN
			SELECT ST.*, SC.Title AS CategoryTitle
			FROM SurveyTable ST 
			LEFT JOIN SurveyCategory SC ON ST.SurveyCategoryId = SC.ID
			where 
			((ST.Permission IS NULL OR ST.Permission = '') OR (@UserId IS NULL) OR Exists(select *from SurveyPermission where UserId = @UserId))
			AND (ST.[Status] = 1 )
			AND (ST.DueDate < Convert(varchar(10), GETDATE(), 21))
			AND (NOT EXISTS (SELECT SR.ID FROM [dbo].[SurveyResponses] SR
									WHERE SR.[SurveyTableId] = ST.[ID] AND [Status]=1))
			AND (@Title IS NULL OR ST.[Title] LIKE ('%'+@Title + '%'))
			AND (@SurveyCategoryId IS NULL OR ST.SurveyCategoryId = @SurveyCategoryId)
			ORDER BY Created DESC
			OFFSET @Offset ROWS
			FETCH NEXT @Limit ROWS ONLY
			END
		ELSE
			BEGIN
				IF(@Type = 0)
				BEGIN
					SELECT ST.*, SC.Title AS CategoryTitle
					FROM SurveyTable ST 
					LEFT JOIN SurveyCategory SC ON ST.SurveyCategoryId = SC.ID
					where 
					((ST.Permission IS NULL OR ST.Permission = '') OR (@UserId IS NULL) OR Exists(select *from SurveyPermission where UserId = @UserId))
					AND (ST.[Status] = 1 )
					AND (ST.DueDate = Convert(varchar(10), GETDATE(), 21))
					AND (ST.[AllowMultipleResponses] = 1 OR 
							NOT EXISTS (SELECT SR.ID FROM [dbo].[SurveyResponses] SR
											WHERE SR.[SurveyTableId] = ST.[ID] AND [Status]=1))
					AND (@Title IS NULL OR ST.[Title] LIKE ('%'+@Title + '%'))
					AND (@SurveyCategoryId IS NULL OR ST.SurveyCategoryId = @SurveyCategoryId)
					ORDER BY Created DESC
					OFFSET @Offset ROWS
					FETCH NEXT @Limit ROWS ONLY
				END
				ELSE
				BEGIN
					SELECT ST.*, SC.Title AS CategoryTitle
					FROM SurveyTable ST 
					LEFT JOIN SurveyCategory SC ON ST.SurveyCategoryId = SC.ID
					where 
					((ST.Permission IS NULL OR ST.Permission = '') OR (@UserId IS NULL) OR Exists(select *from SurveyPermission where UserId = @UserId))
					AND (ST.[Status] = 1 )
					AND (ST.DueDate > Convert(varchar(10), GETDATE(), 21))
					AND (ST.[AllowMultipleResponses] = 1 OR 
							NOT EXISTS (SELECT SR.ID FROM [dbo].[SurveyResponses] SR
											WHERE SR.[SurveyTableId] = ST.[ID] AND [Status]=1))
					AND (@Title IS NULL OR ST.[Title] LIKE ('%'+@Title + '%'))
					AND (@SurveyCategoryId IS NULL OR ST.SurveyCategoryId = @SurveyCategoryId)
					ORDER BY Created DESC
					OFFSET @Offset ROWS
					FETCH NEXT @Limit ROWS ONLY
				END
			END
	END
END

GO
