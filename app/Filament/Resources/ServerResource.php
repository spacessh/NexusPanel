<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ServerResource\Pages;
use App\Models\Server;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class ServerResource extends Resource
{
    protected static ?string $model = Server::class;
    protected static ?string $navigationIcon = 'heroicon-o-server';
    protected static ?string $navigationGroup = 'Infrastructure';
    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('Server Details')->schema([
                Forms\Components\TextInput::make('name')->required()->maxLength(191),
                Forms\Components\Select::make('user_id')->relationship('user', 'name')->required()->searchable(),
                Forms\Components\Select::make('node_id')->relationship('node', 'name')->required()->searchable(),
                Forms\Components\TextInput::make('game_type')->required(),
                Forms\Components\Select::make('status')->options([
                    'offline'  => 'Offline',
                    'online'   => 'Online',
                    'starting' => 'Starting',
                    'stopping' => 'Stopping',
                ])->required(),
            ])->columns(2),

            Forms\Components\Section::make('Resources')->schema([
                Forms\Components\TextInput::make('memory')->numeric()->suffix('MB')->required(),
                Forms\Components\TextInput::make('disk')->numeric()->suffix('MB')->required(),
                Forms\Components\TextInput::make('cpu')->numeric()->suffix('%')->required(),
            ])->columns(3),

            Forms\Components\Section::make('Network')->schema([
                Forms\Components\TextInput::make('ip')->required(),
                Forms\Components\TextInput::make('port')->numeric()->required(),
            ])->columns(2),

            Forms\Components\Textarea::make('startup_command')->required()->columnSpanFull(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('user.name')->label('Owner')->searchable(),
                Tables\Columns\TextColumn::make('node.name')->label('Node'),
                Tables\Columns\BadgeColumn::make('status')->colors([
                    'success' => 'online',
                    'danger'  => 'offline',
                    'warning' => fn ($state) => in_array($state, ['starting', 'stopping']),
                ]),
                Tables\Columns\TextColumn::make('game_type')->label('Game'),
                Tables\Columns\TextColumn::make('ip')->label('IP:Port')
                    ->formatStateUsing(fn ($record) => "{$record->ip}:{$record->port}"),
                Tables\Columns\TextColumn::make('created_at')->dateTime()->sortable()->toggleable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')->options([
                    'online' => 'Online', 'offline' => 'Offline',
                ]),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListServers::route('/'),
            'create' => Pages\CreateServer::route('/create'),
            'edit'   => Pages\EditServer::route('/{record}/edit'),
        ];
    }
}
